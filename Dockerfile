FROM ubuntu:resolute-20261024.1

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=it_IT.UTF-8

ARG ODOO_GID=3328
ARG ODOO_HOMEDIR=/var/lib/odoo
ARG ODOO_UID=3328
ENV ODOO_ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD
ENV ODOO_CONF_FILE=${ODOO_HOMEDIR}/odoo.conf
ENV ODOO_DB=odoodb
ENV ODOO_HOMEDIR=${ODOO_HOMEDIR}
ENV ODOO_CUST_REQ_FILE=${ODOO_HOMEDIR}/requirements.txt
ENV ODOO_UPD_FILE=${ODOO_HOMEDIR}/update.txt
ENV ODOO_VENV=${ODOO_HOMEDIR}/venv
ENV ODOO_VERSION=18.0
ENV ODOO_COMMIT=c2e88e58c732d4e8279f6f11170f0d46a16169de
ENV ODOO_BIN=${ODOO_VENV}/bin/odoo

ARG PG_MAJOR=18
ARG PG_VERSION=18.6
ARG PGDG_FPR=B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
ENV POSTGRES_HOST=db
ENV POSTGRES_PASSWORD=Us3rP4ssw0rD
ENV POSTGRES_USER=odoo

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update && apt-get -y --no-install-recommends install \
    build-essential \
    bzip2 \
    ca-certificates \
    curl \
    default-jre \
    geoip-database \
    git \
    gnupg \
    lftp \
    libbz2-dev \
    libcairo2-dev \
    libffi-dev \
    libgdbm-dev \
    libgeoip1t64 \
    libgirepository1.0-dev \
    libjpeg-dev \
    libldap2-dev \
    liblzma-dev \
    libmagic-dev \
    libncurses-dev \
    libnss3-dev \
    libpq-dev \
    libreadline-dev \
    libreoffice \
    libreoffice-java-common \
    libsasl2-dev \
    libsqlite3-dev \
    libssl-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    libzip-dev \
    libzstd-dev \
    locales \
    lsb-release \
    lzma \
    nano \
    pg-activity \
    procps \
    rsync \
    tdsodbc \
    telnet \
    unzip \
    vim \
    wget \
    xsltproc \
    zlib1g-dev \
    zstd && \
    rm -rf /var/lib/apt/lists/*

RUN apt-get update && \
    curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb -o /tmp/wkhtmltopdf.deb && \
    apt-get -y install /tmp/wkhtmltopdf.deb && \
    rm /tmp/wkhtmltopdf.deb && \
    rm -rf /var/lib/apt/lists/*

RUN set -eu; \
    case "${PG_MAJOR}" in ''|*[!0-9]*) echo "PG_MAJOR non numerico: '${PG_MAJOR}'" >&2; exit 1 ;; esac; \
    case "${PG_VERSION}" in "${PG_MAJOR}".*) : ;; *) echo "PG_VERSION '${PG_VERSION}' non appartiene a PG_MAJOR '${PG_MAJOR}'" >&2; exit 1 ;; esac; \
    . /etc/os-release; \
    key=/tmp/pgdg.asc; \
    curl -fsSL --proto '=https' --proto-redir '=https' --retry 3 --retry-delay 2 \
        -o "${key}" https://www.postgresql.org/media/keys/ACCC4CF8.asc; \
    export GNUPGHOME; GNUPGHOME="$(mktemp -d)"; \
    listing="$(gpg --batch --no-tty --with-colons --show-keys "${key}")"; \
    [ "$(printf '%s\n' "${listing}" | grep -c '^pub:')" -eq 1 ] \
        || { echo "la chiave scaricata non contiene esattamente una chiave pubblica" >&2; exit 1; }; \
    printf '%s\n' "${listing}" | grep -qx "fpr:::::::::${PGDG_FPR}:" \
        || { echo "fingerprint inatteso, atteso ${PGDG_FPR}" >&2; exit 1; }; \
    echo "chiave PGDG verificata: ${PGDG_FPR}"; \
    rm -rf "${GNUPGHOME}"; \
    install -Dm0644 "${key}" /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc; \
    rm -f "${key}"; \
    printf '%s\n' \
        'Types: deb' \
        'URIs: https://apt.postgresql.org/pub/repos/apt' \
        "Suites: ${VERSION_CODENAME}-pgdg" \
        'Components: main' \
        'Signed-By: /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc' \
        > /etc/apt/sources.list.d/pgdg.sources; \
    apt-get update; \
    apt-get install -y --no-install-recommends "postgresql-client-${PG_MAJOR}=${PG_VERSION}*"; \
    rm -rf /var/lib/apt/lists/*

RUN echo ${LANG}" UTF-8" > /etc/locale.gen && locale-gen

RUN groupadd -g ${ODOO_GID} odoo && \
    useradd -l -m -d ${ODOO_HOMEDIR} -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} odoo

COPY --from=ghcr.io/astral-sh/uv:0.12.18 /uv /uvx /bin/
RUN XDG_DATA_HOME=/opt UV_PYTHON_BIN_DIR=/usr/local/bin uv python install 3.12.13

RUN ln -s ${ODOO_BIN} /usr/local/bin/odoo

USER odoo
WORKDIR ${ODOO_HOMEDIR}
EXPOSE 8069 8071 8072
VOLUME ${ODOO_HOMEDIR}

ENV ODOO_SCRIPTS_DIR=/opt/scripts
COPY --chmod=755 opt/scripts/ ${ODOO_SCRIPTS_DIR}/

CMD /bin/bash /opt/scripts/entrypoint.sh