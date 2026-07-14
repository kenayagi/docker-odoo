#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

: "${ODOO_CUST_REQ_FILE:?}"

source "$ODOO_VENV/bin/activate"

if [ ! -f "$ODOO_CUST_REQ_FILE" ]; then
    echo "No customer requirements file, skipping deps update."
else
    echo "Updating customer requirements..."
    uv_install --index-strategy unsafe-best-match -r "$ODOO_CUST_REQ_FILE"

    NOW="$(date +%y%m%d_%H%M%S)"
    mkdir -p "$ODOO_HOMEDIR/log_setup"
    uv pip freeze | sort > "$ODOO_HOMEDIR/log_setup/requirements.txt.${NOW}"

    rm -f "$ODOO_CUST_REQ_FILE"
fi

echo "Customer dependencies setup routine completed."