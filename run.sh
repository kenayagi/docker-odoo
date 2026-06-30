#!/bin/bash

set -Eeuo pipefail

# Remove update files in case of errors
trap 'rm -f "${ODOO_REQ_FILE:-}" "${ODOO_UPD_FILE:-}"' ERR

: "${ODOO_HOMEDIR:?}"
: "${ODOO_CONF_FILE:?}"
: "${ODOO_ADMIN_PASSWD:?}"
: "${ODOO_VENV:?}"
: "${ODOO_VERSION:?}"
: "${ODOO_COMMIT:?}"
: "${ODOO_DB:?}"
: "${POSTGRES_HOST:?}"
: "${POSTGRES_USER:?}"
: "${POSTGRES_PASSWORD:?}"

export NOW=$(date +%y%m%d_%H%M%S)

ODOO_COMMON_ARGS=(
    --config="$ODOO_CONF_FILE"
    --data-dir="$ODOO_HOMEDIR/data_dir"
    --database="$ODOO_DB"
    --db_host="$POSTGRES_HOST"
    --db_password="$POSTGRES_PASSWORD"
    --db_user="$POSTGRES_USER"
)

mkdir -p "$ODOO_HOMEDIR/src"

if [ ! -f "$ODOO_CONF_FILE" ]; then
    printf '[options]\nadmin_passwd = %s\n' "$ODOO_ADMIN_PASSWD" > "$ODOO_CONF_FILE"
else
    sed -i "/^admin_passwd/c\\admin_passwd = $ODOO_ADMIN_PASSWD" "$ODOO_CONF_FILE"
fi

# Check if venv exists
if [ ! -d "$ODOO_VENV" ]; then
    echo "Creating virtual environment at $ODOO_VENV..."
    uv venv "$ODOO_VENV"

    source "$ODOO_VENV/bin/activate"

    echo "Installing base packages..."
    uv pip install --link-mode=hardlink --no-build-isolation setuptools==68.1.2 wheel==0.42.0

    echo "Installing OCB..."
    git clone --depth 1 --branch "$ODOO_VERSION" https://github.com/OCA/OCB.git "$ODOO_HOMEDIR/src/odoo_$ODOO_VERSION"
    cd "$ODOO_HOMEDIR/src/odoo_$ODOO_VERSION"
    git reset --hard $ODOO_COMMIT
    cd "$ODOO_HOMEDIR"
    uv pip install --verbose --prerelease=allow --link-mode=hardlink --no-build-isolation "$ODOO_HOMEDIR/src/odoo_$ODOO_VERSION"

    echo "Installing openupgradelib..."
    uv pip install --verbose --prerelease=allow --link-mode=hardlink --no-build-isolation git+https://github.com/OCA/openupgradelib.git@master

    echo "Virtual environment created and packages installed."
else
    echo "Virtual environment already exists at $ODOO_VENV"
fi

source "$ODOO_VENV/bin/activate"

if [ -f "$ODOO_REQ_FILE" ]; then
    cd "$ODOO_HOMEDIR/src/odoo_$ODOO_VERSION"
    git fetch --depth 1 origin "$ODOO_VERSION"
    git reset --hard "$ODOO_COMMIT"
    uv pip install --verbose --prerelease=allow --link-mode=hardlink --no-build-isolation --upgrade "$ODOO_HOMEDIR/src/odoo_$ODOO_VERSION"
    uv pip install --verbose --prerelease=allow --link-mode=hardlink --no-build-isolation --upgrade --index-strategy unsafe-best-match -r "$ODOO_REQ_FILE"
    mkdir -p "$ODOO_HOMEDIR/log_setup"
    uv pip freeze | sort > "$ODOO_HOMEDIR/log_setup/$NOW.requirements_freeze.txt"
    rm "$ODOO_REQ_FILE"
    cd "$ODOO_HOMEDIR"
fi

# Wait for database
until pg_isready -h "$POSTGRES_HOST" -U "$POSTGRES_USER" >/dev/null 2>&1; do
    echo "Waiting for PostgreSQL..."
    sleep 2
done

# Update
if [ -f "$ODOO_UPD_FILE" ]; then
    "$ODOO_VENV/bin/odoo" "${ODOO_COMMON_ARGS[@]}"\
    --i18n-overwrite \
    --load-language=it_IT \
    --stop-after-init \
    --update="$(< "$ODOO_UPD_FILE")" \
    --workers=0
    rm "$ODOO_UPD_FILE"
fi

# Start
exec "$ODOO_VENV/bin/odoo" "${ODOO_COMMON_ARGS[@]}" \
--geoip-city-db=/usr/share/GeoIP/GeoLite2-City.mmdb \
--geoip-country-db=/usr/share/GeoIP/GeoLite2-Country.mmdb \
--without-demo=ALL
