#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

: "${ODOO_EXPLICIT_REQ_FILE:?}"

if [ ! -s "$ODOO_EXPLICIT_REQ_FILE" ]; then
    echo "No explicit requirements file ($ODOO_EXPLICIT_REQ_FILE), skipping."
else
    source "$ODOO_VENV/bin/activate"

    echo "Installing explicit dependencies from $ODOO_EXPLICIT_REQ_FILE..."
    cat "$ODOO_EXPLICIT_REQ_FILE"

    uv_install \
        --index-strategy unsafe-best-match \
        -r "$ODOO_EXPLICIT_REQ_FILE"

    NOW="$(date +%y%m%d_%H%M%S)"
    mkdir -p "$ODOO_HOMEDIR/log_setup"
    uv pip freeze | sort > "$ODOO_HOMEDIR/log_setup/${NOW}.explicit_deps_freeze.txt"

    echo "Explicit dependencies has been installed."
fi

echo "Explicit dependencies setup routine completed."