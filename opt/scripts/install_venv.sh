#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

if [ -d "$ODOO_VENV" ]; then
    echo "Virtual environment already exists at $ODOO_VENV"
    exit 0
fi

echo "Creating virtual environment at $ODOO_VENV..."
mkdir -p "$ODOO_HOMEDIR/src"
uv venv "$ODOO_VENV"
source "$ODOO_VENV/bin/activate"

echo "Installing base packages..."
uv pip install --link-mode=hardlink --no-build-isolation setuptools==68.1.2 wheel==0.42.0

echo "Installing OCB..."
git clone --depth 1 --branch "$ODOO_VERSION" \
    https://github.com/OCA/OCB.git "$ODOO_SRC_DIR"
sync_ocb_repo
uv_install "$ODOO_SRC_DIR"

echo "Installing openupgradelib..."
uv_install "git+https://github.com/OCA/openupgradelib.git@master"

echo "Virtual environment created and packages installed."