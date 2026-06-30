#!/bin/bash
set -Eeuo pipefail
source "$(dirname "$0")/common.sh"
require_env
: "${ODOO_UPD_FILE:?}"

if [ ! -f "$ODOO_UPD_FILE" ]; then
    echo "No update file, skipping module update."
    exit 0
fi

build_odoo_common_args

MODULES="$(< "$ODOO_UPD_FILE")"
echo "Updating modules: $MODULES"

"$ODOO_VENV/bin/odoo" "${ODOO_COMMON_ARGS[@]}" \
    --i18n-overwrite \
    --load-language=it_IT \
    --stop-after-init \
    --update="$MODULES" \
    --workers=0

rm -f "$ODOO_UPD_FILE"
echo "Module update completed."