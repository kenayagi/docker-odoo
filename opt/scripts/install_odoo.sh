#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

if [ -f "$ODOO_VENV/bin/odoo" ]; then
    echo "Odoo is already installed"
    exit 0
fi

source "$ODOO_VENV/bin/activate"

echo "Installing OCB..."

if [ ! -d "$ODOO_SRC_DIR" ]; then
  git clone --depth 1 --branch "$ODOO_VERSION" \
    https://github.com/OCA/OCB.git "$ODOO_SRC_DIR"
fi
sync_ocb_repo

uv_install "$ODOO_SRC_DIR"

echo "Installing openupgradelib..."
uv_install "git+https://github.com/OCA/openupgradelib.git@master"

echo "Odoo installed."