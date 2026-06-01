#!/bin/sh
set -e

: "${NEO4J_URI:?NEO4J_URI env var is required}"

# RAILWAY_PUBLIC_DOMAIN is set automatically by Railway.
# For local testing you can set PUBLIC_DOMAIN manually.
DOMAIN="${RAILWAY_PUBLIC_DOMAIN:-${PUBLIC_DOMAIN}}"
: "${DOMAIN:?Neither RAILWAY_PUBLIC_DOMAIN nor PUBLIC_DOMAIN is set}"

# Parse bolt host and port from NEO4J_URI (e.g. bolt://neo4j.railway.internal:7687)
_hostport="${NEO4J_URI#*://}"
_hostport="${_hostport%%/*}"
NEO4J_BOLT_HOST="${_hostport%%:*}"
NEO4J_BOLT_PORT="${_hostport##*:}"
[ "$NEO4J_BOLT_PORT" = "$NEO4J_BOLT_HOST" ] && NEO4J_BOLT_PORT=7687
export NEO4J_BOLT_HOST NEO4J_BOLT_PORT

# Generate the Neo4j discovery JSON served at /.
# The browser app fetches this on startup to learn the bolt endpoint.
# bolt+s:// uses WSS, which matches Railway's HTTPS/WSS termination on port 443.
cat > /usr/share/nginx/html/browser-discovery.json <<EOF
{
  "bolt_direct": "bolt+s://${DOMAIN}:443",
  "neo4j_version": "5",
  "neo4j_edition": "community"
}
EOF

# Render the nginx config from its template
envsubst '${NEO4J_BOLT_HOST} ${NEO4J_BOLT_PORT}' \
  < /etc/nginx/nginx.conf.template \
  > /etc/nginx/nginx.conf

exec nginx -g "daemon off;"
