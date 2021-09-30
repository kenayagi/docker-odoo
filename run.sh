#!/bin/bash

NOW=`date +%y%m%d_%H%M%S`

if [ ! -f "$ODOO_CONF_FILE" ]; then
    echo -en "[options]\nproxy_mode = True\naddons_path = /opt/odoo/addons\nadmin_passwd = Db4dm1nSup3rS3cr3tP4ssw0rD" > $ODOO_CONF_FILE
fi

sed -i "/^admin_passwd/c\admin_passwd = $ODOO_ADMIN_PASSWD" $ODOO_CONF_FILE

if [ -f "$ODOO_REQ_FILE" ]; then
    pip install --pre --user --upgrade -r $ODOO_REQ_FILE
    mkdir -p $ODOO_HOMEDIR/setup
    pip freeze --all | sort > $ODOO_HOMEDIR/setup/requirements.$NOW.txt
    rm $ODOO_REQ_FILE
fi

if [ -f "$ODOO_UPD_FILE" ]; then
    /usr/local/bin/odoo --data-dir=$ODOO_HOMEDIR/data_dir --config=$ODOO_CONF_FILE --database=$ODOO_DB --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD \
    --update=$(< $ODOO_UPD_FILE) --load-language=it_IT --i18n-overwrite --workers=0 --stop-after-init
    mkdir -p $ODOO_HOMEDIR/setup
    echo "Modules updated on $NOW: $(< $ODOO_UPD_FILE)" >> $ODOO_HOMEDIR/setup/updates.log
    rm $ODOO_UPD_FILE
fi

/usr/local/bin/odoo --data-dir=$ODOO_HOMEDIR/data_dir --config=$ODOO_CONF_FILE --database=$ODOO_DB --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD \
--geoip-db=/usr/share/GeoIP/GeoIP.dat --without-demo=ALL
