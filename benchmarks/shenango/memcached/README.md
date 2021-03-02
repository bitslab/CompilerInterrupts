# Shenango-Memcached

Memcached port using the shenango runtime.

## Dependencies

* shenango (runtime, net, and base libraries)

## Building
* `$ ./configure --with-shenango=<path to shenango build>`
* `$ make`

## TODOs
* Support `assoc_expand()` function - potentialy requires pausing packet processing
* make settings.num_threads consistent with shenango runtime cfg file