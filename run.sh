#!/bin/bash

set -e

export NOW=`date +%y%m%d_%H%M%S`

if [ ! -f "$ODOO_CONF_FILE" ]; then
    echo -en "[options]\nadmin_passwd = Db4dm1nSup3rS3cr3tP4ssw0rD" > $ODOO_CONF_FILE
fi

sed -i "/^admin_passwd/c\admin_passwd = $ODOO_ADMIN_PASSWD" $ODOO_CONF_FILE

# Check if venv exists
if [ ! -d "$ODOO_VENV" ]; then
    echo "Creating virtual environment..."
    uv venv "$ODOO_VENV"

    source $ODOO_VENV/bin/activate

    echo "Installing base packages..."
    uv pip install --link-mode=copy --no-build-isolation setuptools==68.1.2 wheel==0.42.0

    echo "Installing OCB..."
    uv pip install --prerelease=allow --link-mode=copy --no-build-isolation git+https://github.com/OCA/OCB.git@18.0

    echo "Installing openupgradelib..."
    uv pip install --prerelease=allow --link-mode=copy --no-build-isolation git+https://github.com/OCA/openupgradelib.git@master

    echo "Virtual environment created and packages installed."
else
    echo "Virtual environment already exists at $ODOO_VENV"
fi

source $ODOO_VENV/bin/activate

if [ -f "$ODOO_REQ_FILE" ]; then
    uv sync
    uv pip install --verbose --link-mode=copy --prerelease=allow --index-strategy unsafe-best-match --no-build-isolation --upgrade -r $ODOO_REQ_FILE
    mkdir -p $ODOO_HOMEDIR/log_setup
    uv pip freeze | sort > $ODOO_HOMEDIR/log_setup/$NOW.requirements_freeze.txt
    rm $ODOO_REQ_FILE
fi

if [ -f "$ODOO_UPD_FILE" ]; then
    $ODOO_VENV/bin/odoo \
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

$ODOO_VENV/bin/odoo \
--config=$ODOO_CONF_FILE \
--data-dir=$ODOO_HOMEDIR/data_dir \
--database=$ODOO_DB \
--db_host=$POSTGRES_HOST \
--db_password=$POSTGRES_PASSWORD \
--db_user=$POSTGRES_USER \
--geoip-db=/usr/share/GeoIP/GeoIP.dat \
--without-demo=ALL
