libevent-nacl-port
==================

Native Client port of libevent. The author has limited experience both with Native Client and libevent, so couldn't be less qualified for this task, but was unable to find alternatives at the time of writing this. That being said, this port has been fairly extensively tested on x86_64 in an app that relies on multiple concurrent low-latency UDP streams, in parallel with HTTP gateway functionality. It's performed relatively well, given the nacl_io hack described below.

Usage
-----

1. Check out commit ```18739766...``` of naclports (https://code.google.com/p/naclports/wiki/HowTo_Checkout). I was not able to make anything build using the current head (```f6d0d9c5d1...```).
2. Check out this repo and place its contents under src/ports/libevent in your naclports tree.
3. ```./make_all.sh libevent``` as usual, or whichever way you prefer to build your ports.

Changes
-------

These changes were made in order to make libevent build in the NaCl toolchains:

0. Features from ```sys/uio.h``` such as ```readv()``` and ```writev()``` are just stubs and so always return -1, even though libevent thinks they exist. Disabled the ```HAVE_SYS_UIO_H``` config flag which means libevent will use good ol' ```recv()``` instead, which is conceivably less advanced/efficient.
1. ```mkfifo``` is currently missing from newlib, so I disabled the event-read-fifo test. **TODO**: revisit this.
2. reverse domain name lookups are currently not supported in NaCl (https://groups.google.com/forum/#!topic/native-client-discuss/wE6Gl1NCNys) so exiting with code 1 where ```gethostbyaddr``` was previously called. **TODO**: replace by a stub?
3. newlib doesn't have readv or writev. Inserted implementations obtained from Mike Acton (https://github.com/macton/nativecolors/blob/master/client/src/libraries/nativeblue/readv.c).
4. replaced calls to ```random()```/```srandom()``` (which were missing) by ```rand()```/```srand()``` ditto.
5. ```SA_RESTART``` and ```SA_NODEFER``` were missing, so I took a queue from the python port: https://code.google.com/p/naclports/source/browse/trunk/src/ports/python3/nacl.patch?r=998#130 and defined them.
6. libevent's configure script resets the ```LIBS``` var before checking for ```SSL_new()```, which breaks a dependency and results in no SSL support. I removed the offending line.
7. NaCl only provides stubs (i.e. non-working shells) for ```getnameinfo``` and ```getaddrinfo```, so I'm forcibly disabling those in ```config.h``` in favor of libevent's built-in ones.
8. Ditto for various timer related functions (e.g. ```timeradd```).

nacl_io hack
------------

nacl_io currently suffers from a debilitating limitation in UDP functionality in that it doesn't properly queue outbound datagrams, as outlined in this thread:
https://code.google.com/p/chromium/issues/detail?id=154338

While we await a proper fix, I was able to make the UDP send call synchronous by hacking **udp_node.cc** and inserting the ```PP_BlockUntilComplete``` completion callback into the ```SendTo``` call (more info here: https://developer.chrome.com/native-client/pepper_dev/c/group___functions). This is a crucial tweak for any non-trivial application of UDP traffic in NaCl, and I will post a diff here when time permits.

Performance
-----------

All in all it seems we're missing quite a bunch of Socket API calls compared to, say, a modern Linux distro. How much of a performance hit this is though - and whether it's even a blip on the radar compared to the Pepper API overhead - remains to be seen. I'll add info here once I have it.

Notice
------

Experimental, mostly untested code! The author takes no responsibility whatsoever for the contents or functionality of this software.
