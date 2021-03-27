#!/bin/bash

cd /usr/local && ./bin/janus -b -C ./etc/janus/janus.jcfg -L /dev/null &&
cd /usr/local && ./bin/httpx-static -t 8080 -r ./share/janus/demos/ -p http://127.0.0.1:8088/janus
