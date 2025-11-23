#!/bin/sh
set -eu

# Ensure data/public/hooks folders exist for mounted volumes
mkdir -p /pb_data /pb_public /pb_hooks

PB_HOST="${PB_HOST:-0.0.0.0}"
PB_PORT="${PB_PORT:-8090}"

create_superuser() {
  if [ -n "${PB_ADMIN_EMAIL:-}" ] && [ -n "${PB_ADMIN_PASSWORD:-}" ]; then
    /usr/local/bin/pocketbase superuser upsert "${PB_ADMIN_EMAIL}" "${PB_ADMIN_PASSWORD}" --dir /pb_data
  fi
}

set_default_serve() {
  set -- serve --http "${PB_HOST}:${PB_PORT}" --dir /pb_data --publicDir /pb_public --hooksDir /pb_hooks "$@"
}

# If no command passed, serve with defaults
if [ "$#" -eq 0 ]; then
  set_default_serve
fi

# Global flags passthrough
case "$1" in
  --help|-h|--version|-v)
    exec /usr/local/bin/pocketbase "$@"
    ;;
esac

# If first argument starts with '-', treat as serve args
if [ "${1#-}" != "$1" ]; then
  set_default_serve "$@"
fi

# Automatically add encryption flag when ENCRYPTION env is set
if [ "${1:-}" = "serve" ] && [ -n "${ENCRYPTION:-}" ]; then
  set -- "$@" --encryptionEnv ENCRYPTION
fi

# Auto-create or update superuser when running the server
if [ "${1:-}" = "serve" ]; then
  create_superuser
fi

exec /usr/local/bin/pocketbase "$@"
