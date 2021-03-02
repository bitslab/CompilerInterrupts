#!/bin/bash
ulimit -c unlimited
./cpuminer -a sha256d -o stratum+tcp://connect.pool.bitcoin.com:3333 -u 15dFNAbSnC7MngwHjoM2gZSuCEg5mmAEKc -p c=BTC
