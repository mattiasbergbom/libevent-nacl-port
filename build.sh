#!/bin/bash
#
# Copyright (c) 2014 SwarmPlanet AB. All rights reserved.
#

BUILD_DIR=${SRC_DIR}
INSTALL_TARGETS="install_sw INSTALL_PREFIX=${DESTDIR}"

ConfigureStep() {

  # this is the default:
  local host=${NACL_ARCH}

  # consistency doesn't seem to be the NaCl:ers'
  # strongest suit...
  if [ "${NACL_ARCH}" = "pnacl" ] ; then 
      local nacl_lib=pnacl
      local host=i686
      local extra_libs="-lc++"
  else
          # i686 maps to x86_32 (at least on Ubuntu 12.04 64-bit...)
      if [ "${NACL_ARCH}" = "i686" ] ; then 
	      local arch=x86_32
      else
	  local arch=${NACL_ARCH}
      fi
      local nacl_lib=${NACL_LIBC}_${arch}
      local extra_libs=""
  fi

  if [ "${NACL_LIBC}" = "newlib" ] ; then
      # --------------------------
      # newlib (needs glibc-compat)
      # --------------------------

      local libs="-lnacl_io -lstdc++ -lpthread ${extra_libs}"
      local ldflags="-L${NACL_SDK_ROOT}/lib/${nacl_lib}/Release"
      local cflags="-O2 -I${NACLPORTS_INCLUDE}/glibc-compat -I${NACL_SDK_ROOT}/include"
  else
      # --------------------------
      # glibc
      # --------------------------
      local arch=${NACL_ARCH}
      local ldflags="-L${NACL_SDK_ROOT}/lib/${nacl_lib}/Release"
      local cflags="-O2 -I${NACL_SDK_ROOT}/include"
      local libs="-lnacl_io"
  fi
  # bash seems incapable of passing space-delimited lists of env vars via commandline,
  # so passing via environment instead (ugly, but works)
  echo export "LDFLAGS=\"$ldflags\""
  echo export "CFLAGS=\"$cflags\""
  echo export "LIBS=\"$libs\""
  export LDFLAGS=$ldflags
  export CFLAGS=$cflags
  export LIBS=$libs
  touch configure.ac aclocal.m4 configure Makefile.am Makefile.in
  rm -fv config.h
  LogExecute env CC=${NACLCC} AR=${NACLAR} RANLIB=${NACLRANLIB} ./configure --prefix=${PREFIX} --host=${host}
  
  # fix OpenSSL includes
  perl -i -pe 's|^(DEFAULT_INCLUDES[ ]*=.*)|\1 \$(OPENSSL_INCS)|g' Makefile

}


BuildStep() {
    LogExecute make clean
    LogExecute make config.h

    # fix getnameinfo / getaddrinfo that are currently just stubs
    # ("The plan is to add this, but I don't see it as urgent.  python in naclports has been configured
    # not to use it.  Are you running into other places where not having this function is a problem?")
    perl -i -pe 's|#define HAVE_GETNAMEINFO 1|//#define HAVE_GETNAMEINFO 1|g' config.h
    perl -i -pe 's|#define HAVE_GETADDRINFO 1|//#define HAVE_GETADDRINFO 1|g' config.h

    # sys/uio.h and associated functions are currently merely stubs in NaCl. Tell libevent to make
    # do without them:
    perl -i -pe 's|#define HAVE_SYS_UIO_H 1|//#define HAVE_SYS_UIO_H 1|g' config.h

    # timer functionality that's only stubbed out in NaCl. Tell libevent to make
    # do without them:
    perl -i -pe 's|#define HAVE_TIMERADD 1|//#define HAVE_TIMERADD 1|g' config.h
    perl -i -pe 's|#define HAVE_TIMERCLEAR 1|//#define HAVE_TIMERCLEAR 1|g' config.h
    perl -i -pe 's|#define HAVE_TIMERCMP 1|//#define HAVE_TIMERCMP 1|g' config.h
    perl -i -pe 's|#define HAVE_TIMERISSET 1|//#define HAVE_TIMERISSET 1|g' config.h

    DefaultBuildStep
}


InstallStep() {
  DESTDIR=${DESTDIR} make install
}

TestStep() {
    make verify
}
