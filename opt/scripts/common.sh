#!/bin/bash

# Env variables validation
require_env() {
    : "${ODOO_HOMEDIR:?}"
    : "${ODOO_CONF_FILE:?}"
    : "${ODOO_VENV:?}"
    : "${ODOO_VERSION:?}"
    : "${ODOO_COMMIT:?}"
    : "${ODOO_DB:?}"
    : "${POSTGRES_HOST:?}"
    : "${POSTGRES_USER:?}"
    : "${POSTGRES_PASSWORD:?}"
}

ODOO_BASE_REQ_FILE="${ODOO_BASE_REQ_FILE:-${ODOO_HOMEDIR}/odoo_base_requirements.txt}"
ODOO_SRC_DIR="${ODOO_HOMEDIR}/src/odoo_${ODOO_VERSION}"

# Common odoo args
build_odoo_common_args() {
    ODOO_COMMON_ARGS=(
        --config="$ODOO_CONF_FILE"
        --data-dir="$ODOO_HOMEDIR/data_dir"
        --database="$ODOO_DB"
        --db_host="$POSTGRES_HOST"
        --db_password="$POSTGRES_PASSWORD"
        --db_user="$POSTGRES_USER"
    )
}

# Wrapper uv pip install standard
uv_install() {
    uv pip install \
        --link-mode=copy \
        --prerelease=allow \
        --upgrade \
        "$@"
}

# Update OCB to pinned commit
sync_ocb_repo() {
    cd "$ODOO_SRC_DIR"
    git fetch --depth 1 origin "$ODOO_COMMIT"
    git reset --hard FETCH_HEAD
    cd "$ODOO_HOMEDIR"
}