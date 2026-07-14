#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

if [ -d "$ODOO_VENV" ]; then
    echo "Virtual environment already exists at $ODOO_VENV"
else
    echo "Creating virtual environment at $ODOO_VENV..."
    mkdir -p "$ODOO_HOMEDIR/src"
    uv venv "$ODOO_VENV"
    source "$ODOO_VENV/bin/activate"

    echo "Installing base packages..."
    uv_install setuptools==68.1.2 wheel==0.42.0
fi

echo "Virtual environment is ready."