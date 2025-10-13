#!/bin/sh
set -e

: "${API_URL:=}"
: "${INTERNAL_BACKEND_HOST:=backend}"
: "${INTERNAL_BACKEND_PORT:=5000}"
export API_URL INTERNAL_BACKEND_HOST INTERNAL_BACKEND_PORT

envsubst '$API_URL' < /usr/share/nginx/html/app.js > /usr/share/nginx/html/app.js.tmp
mv /usr/share/nginx/html/app.js.tmp /usr/share/nginx/html/app.js

envsubst '$INTERNAL_BACKEND_HOST $INTERNAL_BACKEND_PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp
mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf

exec "$@"
