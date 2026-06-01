#!/bin/sh
set -e

# Derive NEO4J_BOLT_HOST and NEO4J_BOLT_PORT from NEO4J_URI.
# NEO4J_URI is expected in the form: bolt://host:port or neo4j://host:port
: "${NEO4J_URI:?NEO4J_URI env var is required}"

# Strip scheme (bolt://, neo4j://, bolt+routing://, etc.)
_hostport="${NEO4J_URI#*://}"
# Strip any trailing path
_hostport="${_hostport%%/*}"

NEO4J_BOLT_HOST="${_hostport%%:*}"
NEO4J_BOLT_PORT="${_hostport##*:}"
# Default to 7687 if no port in URI
[ "$NEO4J_BOLT_PORT" = "$NEO4J_BOLT_HOST" ] && NEO4J_BOLT_PORT=7687

export NEO4J_BOLT_HOST NEO4J_BOLT_PORT

envsubst '${NEO4J_BOLT_HOST} ${NEO4J_BOLT_PORT}' \
  < /etc/nginx/nginx.conf.template \
  > /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
