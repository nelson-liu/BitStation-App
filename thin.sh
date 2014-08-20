#!/bin/sh
bundle exec thin start -p 3000 --ssl --ssl-key-file certs/server.key --ssl-cert-file certs/server.crt
