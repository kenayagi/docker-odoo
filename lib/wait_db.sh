#!/bin/bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
require_env

until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" >/dev/null 2>&1; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done
echo "PostgreSQL is ready."