#!/bin/bash

cd /usr/local && ./bin/httpx-static -t 8080 -s 8443 -k ./etc/server.key -c ./etc/server.crt \
  -r ./share/janus/demos/ -p http://127.0.0.1:8088/janus 1>/dev/null 2>/dev/null &
/usr/local/bin/janus $*

