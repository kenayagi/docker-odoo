#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

if [ -f "$ODOO_VENV/bin/odoo" ]; then
    echo "Odoo is already installed"
    exit 0
fi

echo "Installing OCB..."

if [ ! -d "$ODOO_SRC_DIR" ]; then
  git clone --depth 1 --branch "$ODOO_VERSION" \
    https://github.com/OCA/OCB.git "$ODOO_SRC_DIR"
fi

# Get current commit hash in the repository
current_commit=$(cd "$ODOO_SRC_DIR" && git rev-parse HEAD)

# Sync the repository to the desired commit
sync_ocb_repo

# Get the new commit hash after sync
new_commit=$(cd "$ODOO_SRC_DIR" && git rev-parse HEAD)

# Only upgrade if the commit has changed
if [ "$current_commit" != "$new_commit" ]; then
    echo "Odoo commit changed from $current_commit to $new_commit, upgrading..."
    uv_install "$ODOO_SRC_DIR"
else
    echo "Odoo commit hasn't changed, skipping upgrade."
fi

echo "Installing openupgradelib..."
uv_install "git+https://github.com/OCA/openupgradelib.git@master"

echo "Odoo installed."