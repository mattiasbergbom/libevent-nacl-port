#!/bin/bash
#
# Copyright (c) 2014 SwarmPlanet AB. All rights reserved.
#

BUILD_DIR=${SRC_DIR}
INSTALL_TARGETS="install_sw INSTALL_PREFIX=${DESTDIR}"

ConfigureStep() {

  # this is the default:
  local host=${NACL_ARCH}

  if [ "${NACL_LIBC}" = "newlib" ] ; then
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
	  local nacl_lib=newlib_${arch}
	  local extra_libs=""
      fi
      local libs="-lnacl_io -lstdc++ -lpthread ${extra_libs}"
      local ldflags="-L${NACL_SDK_ROOT}/lib/${nacl_lib}/Release"
      local cflags="-I${NACLPORTS_INCLUDE}/glibc-compat -I${NACL_SDK_ROOT}/include"
  else
      # glibc defaults:
      local arch=${NACL_ARCH}
      local ldflags=""
      local cflags=""
      local libs=""
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
  LogExecute env CC=${NACLCC} AR=${NACLAR} RANLIB=${NACLRANLIB} ./configure --prefix=${PREFIX} --host=${host}
  
  # fix OpenSSL includes
  perl -i -pe 's|^(DEFAULT_INCLUDES[ ]*=.*)|\1 \$(OPENSSL_INCS)|g' Makefile

}


BuildStep() {
  LogExecute make clean
  DefaultBuildStep
}


InstallStep() {
  #DefaultInstallStep
  DESTDIR=${DESTDIR} make install
}

TestStep() {
    make verify
}
