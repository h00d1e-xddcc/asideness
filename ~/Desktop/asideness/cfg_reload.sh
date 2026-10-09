#!/bin/bash

 exec 3<>/dev/tcp/127.0.0.1/9000
 echo "my_func" >&3
 exec 3>&-
 | nc 127.0.0.1 9000