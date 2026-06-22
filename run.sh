#!/bin/bash

set -e

export NOW=`date +%y%m%d_%H%M%S`

if [ ! -f "$ODOO_CONF_FILE" ]; then
    echo -en "[options]\nadmin_passwd = Db4dm1nSup3rS3cr3tP4ssw0rD" > $ODOO_CONF_FILE
fi

sed -i "/^admin_passwd/c\admin_passwd = $ODOO_ADMIN_PASSWD" $ODOO_CONF_FILE

# Check if pyproject.toml exists
if [ ! -f "pyproject.toml" ]; then
    echo "Initializing uv project in $ODOO_HOMEDIR..."
    uv init --no-package --name docker-odoo --python 3.12
fi

# Check if venv exists
if [ ! -d "$ODOO_VENV" ]; then
    echo "Creating virtual environment at $ODOO_VENV..."
    uv venv "$ODOO_VENV"

    echo "Installing base packages..."
    uv add --verbose --link-mode=copy --active setuptools==68.1.2 wheel==0.42.0

    echo "Installing OCB..."
    git clone --depth 1 --branch 18.0 https://github.com/OCA/OCB.git odoo18
    # Remove pyproject.toml from OCB if it exists to avoid uv validation errors
    if [ -f "odoo18/pyproject.toml" ]; then
        rm odoo18/pyproject.toml
    fi
    if [ -f "odoo18/requirements.txt" ]; then
        uv add --verbose --prerelease=allow --link-mode=copy --active -r odoo18/requirements.txt
    fi
    uv add --verbose --prerelease=allow --link-mode=copy --active --no-workspace ./odoo18

    echo "Installing openupgradelib..."
    uv add --verbose --prerelease=allow --link-mode=copy --active git+https://github.com/OCA/openupgradelib.git@master

    echo "Project initialized and packages installed."
else
    echo "Virtual environment already exists at $ODOO_VENV"
fi

if [ -f "$ODOO_REQ_FILE" ]; then
    uv add --verbose --upgrade --prerelease=allow --index-strategy unsafe-best-match --link-mode=copy --active -r $ODOO_REQ_FILE
    mkdir -p $ODOO_HOMEDIR/log_setup
    uv export --no-hashes --format requirements-txt > $ODOO_HOMEDIR/log_setup/$NOW.requirements_freeze.txt
    rm $ODOO_REQ_FILE
fi

if [ -f "$ODOO_UPD_FILE" ]; then
    uv run odoo \
    --config=$ODOO_CONF_FILE \
    --data-dir=$ODOO_HOMEDIR/data_dir \
    --database=$ODOO_DB \
    --db_host=$POSTGRES_HOST \
    --db_password=$POSTGRES_PASSWORD \
    --db_user=$POSTGRES_USER \
    --i18n-overwrite \
    --load-language=it_IT \
    --stop-after-init \
    --update=$(< $ODOO_UPD_FILE) \
    --workers=0
    rm $ODOO_UPD_FILE
fi

uv run odoo \
--config=$ODOO_CONF_FILE \
--data-dir=$ODOO_HOMEDIR/data_dir \
--database=$ODOO_DB \
--db_host=$POSTGRES_HOST \
--db_password=$POSTGRES_PASSWORD \
--db_user=$POSTGRES_USER \
--geoip-db=/usr/share/GeoIP/GeoIP.dat \
--without-demo=ALL
