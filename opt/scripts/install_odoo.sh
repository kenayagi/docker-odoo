#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env
source "$ODOO_VENV/bin/activate"

if [ -f "$ODOO_VENV/bin/odoo" ]; then
    echo "Odoo has already been installed."

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
        echo "Odoo has been upgraded."
    else
        echo "Odoo $ODOO_VERSION commit hasn't changed, skipping upgrade."
    fi

else
    echo "Installing OCB..."
    if [ ! -d "$ODOO_SRC_DIR" ]; then
      git clone --depth 1 --branch "$ODOO_VERSION" \
        https://github.com/OCA/OCB.git "$ODOO_SRC_DIR"
    fi
    sync_ocb_repo

    uv_install "$ODOO_SRC_DIR"

    echo "Installing openupgradelib..."
    uv_install "git+https://github.com/OCA/openupgradelib.git@master"
fi

echo "Odoo installation is ready."