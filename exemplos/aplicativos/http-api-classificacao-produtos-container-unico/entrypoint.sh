#!/bin/bash

gunicorn -w 4 -b 127.0.0.1:5000 app:app &
nginx -g 'daemon off;' &
  
wait -n
  
exit $?