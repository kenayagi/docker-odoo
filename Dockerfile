FROM ubuntu:jammy-20260109

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=it_IT.UTF-8

ARG ODOO_GID=3328
ARG ODOO_HOMEDIR=/var/lib/odoo
ARG ODOO_UID=3328
ENV ODOO_ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD
ENV ODOO_CONF_FILE=${ODOO_HOMEDIR}/odoo.conf
ENV ODOO_DB=odoodb
ENV ODOO_HOMEDIR=${ODOO_HOMEDIR}
ENV ODOO_REQ_FILE=${ODOO_HOMEDIR}/requirements.txt
ENV ODOO_UPD_FILE=${ODOO_HOMEDIR}/update.txt
ENV ODOO_VENV=${ODOO_HOMEDIR}/venv

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
    libgeoip1 \
    libgirepository1.0-dev \
    libjpeg-dev \
    libldap2-dev \
    liblzma-dev \
    libmagic-dev \
    libncurses5-dev \
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

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install postgresql-client-16 && \
    rm -rf /var/lib/apt/lists/*

RUN echo ${LANG}" UTF-8" > /etc/locale.gen && locale-gen

RUN groupadd -g ${ODOO_GID} odoo && \
    useradd -l -m -d ${ODOO_HOMEDIR} -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} odoo

COPY --from=ghcr.io/astral-sh/uv:0.10.2 /uv /uvx /bin/
RUN XDG_DATA_HOME=/opt UV_PYTHON_BIN_DIR=/usr/local/bin uv python install 3.10.12

USER odoo
WORKDIR ${ODOO_HOMEDIR}
EXPOSE 8069 8071 8072
VOLUME ${ODOO_HOMEDIR}

COPY run.sh /run.sh
CMD /bin/bash /run.sh
