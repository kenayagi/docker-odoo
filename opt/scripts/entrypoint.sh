#!/bin/bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
source "${SCRIPT_DIR}/common.sh"
require_env

# Cleanup update files in case of error
trap 'rm -f "${ODOO_REQ_FILE:-}" "${ODOO_UPD_FILE:-}"' ERR

# Config file parsing
if [ ! -f "$ODOO_CONF_FILE" ]; then
    printf '[options]\nadmin_passwd = %s\n' "${ODOO_ADMIN_PASSWD:?}" > "$ODOO_CONF_FILE"
else
    sed -i "/^admin_passwd/c\\admin_passwd = ${ODOO_ADMIN_PASSWD:?}" "$ODOO_CONF_FILE"
fi

# Pipeline
"$SCRIPT_DIR/install_venv.sh"
"$SCRIPT_DIR/install_explicit_deps.sh"
"$SCRIPT_DIR/install_odoo.sh"
"$SCRIPT_DIR/update_deps.sh"
"$SCRIPT_DIR/wait_db.sh"
"$SCRIPT_DIR/update_odoo.sh"

# Start
source "$ODOO_VENV/bin/activate"
build_odoo_common_args

GEO_ARGS=()
[ -f /usr/share/GeoIP/GeoLite2-City.mmdb ] && \
    GEO_ARGS+=(--geoip-city-db=/usr/share/GeoIP/GeoLite2-City.mmdb)
[ -f /usr/share/GeoIP/GeoLite2-Country.mmdb ] && \
    GEO_ARGS+=(--geoip-country-db=/usr/share/GeoIP/GeoLite2-Country.mmdb)

exec "$ODOO_VENV/bin/odoo" "${ODOO_COMMON_ARGS[@]}" \
    "${GEO_ARGS[@]}" \
    --without-demo=ALL