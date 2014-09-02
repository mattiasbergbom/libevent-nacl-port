libevent-nacl-port
==================

NaCl port of libevent. NOTE: this is work in progress. It builds successfully on Ubuntu 12.04 but I have yet to verify that it actually works in any practical circumstances.

Usage
-----

1. Check out commit ```18739766...``` of naclports (https://code.google.com/p/naclports/wiki/HowTo_Checkout). I was not able to make anything build using the current head (```f6d0d9c5d1...```).
2. Check out this directory and place its contents under src/ports/libevent in your naclports tree.
3. ```./make_all.sh libevent``` as usual, or whichever way you prefer to build your ports.

Changes
-------

These changes were made in order to make libevent build in the NaCl toolchains:

1. ```mkfifo``` is currently missing from newlib, so I disabled the event-read-fifo test.
2. reverse domain name lookups are currently not supported in NaCl (https://groups.google.com/forum/#!topic/native-client-discuss/wE6Gl1NCNys) so exiting with code 1 where ```gethostbyaddr``` was previously called. TODO: replace by a stub?
3. newlib doesn't have readv or writev. Inserted implementations obtained from Mike Acton (https://github.com/macton/nativecolors/blob/master/client/src/libraries/nativeblue/readv.c).
4. replaced calls to ```random()```/```srandom()``` (which were missing) by ```rand()```/```srand()``` ditto.
5. newlib doesn't have ```itimerval``` or related calls, so I removed tests that use them.
6. ```SA_RESTART``` and ```SA_NODEFER``` were missing, so I took a queue from the python port: https://code.google.com/p/naclports/source/browse/trunk/src/ports/python3/nacl.patch?r=998#130 and defined them.
7. libevent's configure script resets the ```LIBS``` var before checking for ```SSL_new()```, which breaks a dependency and results in no SSL support. I removed the offending line.

Notice
------

Experimental, mostly untested code! The author takes no responsibility whatsoever for the contents or functionality of this software.
