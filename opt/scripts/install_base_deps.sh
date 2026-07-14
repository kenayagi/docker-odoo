#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

: "${ODOO_BASE_REQ_FILE:?}"

if [ ! -s "$ODOO_BASE_REQ_FILE" ]; then
    echo "No base requirements file ($ODOO_BASE_REQ_FILE), skipping."
else
    source "$ODOO_VENV/bin/activate"

    echo "Installing base dependencies from $ODOO_BASE_REQ_FILE..."

    uv_install \
        --index-strategy unsafe-best-match \
        -r "$ODOO_BASE_REQ_FILE"

    NOW="$(date +%y%m%d_%H%M%S)"
    mkdir -p "$ODOO_HOMEDIR/log_setup"
    uv pip freeze | sort > "$ODOO_HOMEDIR/log_setup/${NOW}.base_deps_freeze.txt"

    rm -f "$ODOO_BASE_REQ_FILE"

    echo "Base dependencies has been installed."
fi

echo "Base dependencies setup routine completed."