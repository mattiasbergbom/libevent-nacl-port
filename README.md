libevent-nacl-port
==================

NaCl port of libevent. NOTE: this is work in progress. It builds successfully on Ubuntu 12.04 but I have yet to verify that it actually functions in any meaningful way. 

**UPDATE**: I was able to get a trivial UDP listener to work using the current configuration. Will post example code when time allows.

**UPDATE 2**: I have now also been able to get a trivial HTTP server running. Example code when time permits.

Usage
-----

1. Check out commit ```18739766...``` of naclports (https://code.google.com/p/naclports/wiki/HowTo_Checkout). I was not able to make anything build using the current head (```f6d0d9c5d1...```).
2. Check out this repo and place its contents under src/ports/libevent in your naclports tree.
3. ```./make_all.sh libevent``` as usual, or whichever way you prefer to build your ports.

Changes
-------

These changes were made in order to make libevent build in the NaCl toolchains:

0. Features from ```sys/uio.h``` such as ```readv()``` and ```writev()``` are just stubs and so always return -1, even though libevent thinks they exist. Disabled the ```HAVE_SYS_UIO_H``` config flag which means libevent will use good ol' ```recv()``` instead, which is conceivably less advanced/efficient.
1. ```mkfifo``` is currently missing from newlib, so I disabled the event-read-fifo test.
2. reverse domain name lookups are currently not supported in NaCl (https://groups.google.com/forum/#!topic/native-client-discuss/wE6Gl1NCNys) so exiting with code 1 where ```gethostbyaddr``` was previously called. **TODO**: replace by a stub?
3. newlib doesn't have readv or writev. Inserted implementations obtained from Mike Acton (https://github.com/macton/nativecolors/blob/master/client/src/libraries/nativeblue/readv.c).
4. replaced calls to ```random()```/```srandom()``` (which were missing) by ```rand()```/```srand()``` ditto.
5. ```SA_RESTART``` and ```SA_NODEFER``` were missing, so I took a queue from the python port: https://code.google.com/p/naclports/source/browse/trunk/src/ports/python3/nacl.patch?r=998#130 and defined them.
6. libevent's configure script resets the ```LIBS``` var before checking for ```SSL_new()```, which breaks a dependency and results in no SSL support. I removed the offending line.
7. NaCl only provides stubs (i.e. non-working shells) for ```getnameinfo``` and ```getaddrinfo```, so I'm forcibly disabling those in ```config.h``` in favor of libevent's homegrown ones.

Performance
-----------

All in all it seems we're missing quite a bunch of Socket API calls compared to, say, a modern Linux distro. How much of a performance hit this is though - and whether it's even a blip on the radar compared to the Pepper API overhead - remains to be seen. I'll add info here once I have it.

Notice
------

Experimental, mostly untested code! The author takes no responsibility whatsoever for the contents or functionality of this software.
