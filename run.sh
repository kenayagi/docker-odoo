#!/bin/bash

if [ -f $ODOO_DATADIR/$REQ_FILE ]; then
    pip install --pre --user --upgrade -r $REQ_PATH
    mkdir -p $ODOO_DATADIR/setup
    mv $REQ_PATH $ODOO_DATADIR/setup/requirements-installed-on-`date +%y%m%d`-at-`date +%H%M%S`.txt
fi

sed -i "/^admin_passwd/c\admin_passwd=$ADMIN_PASSWD" $ODOO_CONF

/usr/local/bin/odoo --data-dir=$ODOO_DATADIR --config=$ODOO_CONF --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD
