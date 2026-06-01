#!/bin/sh
set -e

# Substitute NEO4J_INTERNAL_HOST into the nginx config template,
# then hand off to nginx.
: "${NEO4J_INTERNAL_HOST:?NEO4J_INTERNAL_HOST env var is required}"

envsubst '${NEO4J_INTERNAL_HOST}' \
  < /etc/nginx/nginx.conf.template \
  > /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
