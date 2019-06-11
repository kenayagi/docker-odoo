#!/bin/bash

REQ_PATH=/var/lib/odoo/setup/requirements.txt

if [ -f $REQ_PATH ]; then
    pip install --pre --user --upgrade -r $REQ_PATH
    mkdir -p /var/lib/odoo/setup/done
    mv $REQ_PATH /var/lib/odoo/setup/done/installed-on-`date +%y%m%d`-at-`date +%H%M%S`.txt
fi

/usr/local/bin/odoo --data-dir=/var/lib/odoo --config=/etc/odoo/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD
