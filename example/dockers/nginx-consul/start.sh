#!/bin/bash

# Start nginx and consul-template
consul-template -config /etc/consul-template/config.cfg > /var/log/consul-template.log&
nginx -c /etc/nginx/nginx.conf -t && \
nginx -c /etc/nginx/nginx.conf -g "daemon off;"
