#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

: "${ODOO_REQ_FILE:?}"

source "$ODOO_VENV/bin/activate"

# Get current commit hash in the repository
current_commit=$(cd "$ODOO_SRC_DIR" && git rev-parse HEAD)
echo "Current Odoo $ODOO_VERSION is at commit $current_commit"

# Sync the repository to the desired commit
sync_ocb_repo

# Get the new commit hash after sync
new_commit=$(cd "$ODOO_SRC_DIR" && git rev-parse HEAD)

# Only upgrade if the commit has changed
if [ "$current_commit" != "$new_commit" ]; then
    echo "Upgrading Odoo $ODOO_VERSION from $current_commit to $new_commit..."
    uv_install "$ODOO_SRC_DIR"
else
    echo "Odoo $ODOO_VERSION commit hasn't changed, skipping upgrade."
fi

if [ ! -f "$ODOO_REQ_FILE" ]; then
    echo "No requirements file, skipping deps update."
else
    echo "Updating requirements..."
    uv_install --index-strategy unsafe-best-match -r "$ODOO_REQ_FILE"

    NOW="$(date +%y%m%d_%H%M%S)"
    mkdir -p "$ODOO_HOMEDIR/log_setup"
    uv pip freeze | sort > "$ODOO_HOMEDIR/log_setup/${NOW}.requirements_freeze.txt"

    rm -f "$ODOO_REQ_FILE"
fi

echo "Dependencies update completed."