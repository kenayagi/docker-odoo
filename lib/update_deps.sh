#!/bin/bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
require_env
: "${ODOO_REQ_FILE:?}"

if [ ! -f "$ODOO_REQ_FILE" ]; then
    echo "No requirements update file, skipping deps update."
    exit 0
fi

source "$ODOO_VENV/bin/activate"

echo "Updating OCB to commit $ODOO_COMMIT..."
sync_ocb_repo
uv_install --upgrade "$ODOO_SRC_DIR"

echo "Updating custom requirements..."
uv_install --upgrade --index-strategy unsafe-best-match -r "$ODOO_REQ_FILE"

NOW="$(date +%y%m%d_%H%M%S)"
mkdir -p "$ODOO_HOMEDIR/log_setup"
uv pip freeze | sort > "$ODOO_HOMEDIR/log_setup/${NOW}.requirements_freeze.txt"

rm -f "$ODOO_REQ_FILE"
echo "Dependencies update completed."