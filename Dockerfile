FROM debian:trixie

ENV DEBIAN_FRONTEND=noninteractive

ARG ODOO_UID=3328
ARG ODOO_GID=3328
ARG ODOO_HOMEDIR=/var/lib/odoo
ENV ODOO_HOMEDIR=${ODOO_HOMEDIR}

ENV ODOO_DB=odoodb
ENV ODOO_CONF_FILE=${ODOO_HOMEDIR}/odoo.conf
ENV ODOO_UPD_FILE=${ODOO_HOMEDIR}/update.txt
ENV ODOO_REQ_FILE=${ODOO_HOMEDIR}/requirements.txt
ENV ODOO_ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD

ENV PYTHON_VERSION=3.10.12

ENV POSTGRES_HOST=db
ENV POSTGRES_USER=odoo
ENV POSTGRES_PASSWORD=Us3rP4ssw0rD

ENV LANG=it_IT.UTF-8

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
    libxslt-dev \
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

RUN curl -L https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz -o /tmp/Python-${PYTHON_VERSION}.tgz && \
    cd /tmp/ && \
    tar -xf /tmp/Python-${PYTHON_VERSION}.tgz && \
    cd /tmp/Python-${PYTHON_VERSION} && \
    ./configure \
    --enable-optimizations \
    --enable-option-checking=fatal \
    --enable-shared \
    --prefix=/usr/local \
    --with-lto && \
    make -j$(nproc) && \
    make altinstall && \
    cd / && \
    rm /tmp/Python-${PYTHON_VERSION}.tgz && \
    rm -R /tmp/Python-${PYTHON_VERSION} && \
    update-alternatives --install /usr/bin/python python /usr/local/bin/python${PYTHON_VERSION%.*} 1 && \
    update-alternatives --install /usr/bin/pip pip /usr/local/bin/pip${PYTHON_VERSION%.*} 1

COPY --from=ghcr.io/astral-sh/uv:0.9.1-python3.10-trixie /usr/local/bin/uv /usr/local/bin/uvx /bin/

RUN apt-get update && \
    curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.bullseye_amd64.deb -o /tmp/wkhtmltopdf.deb && \
    apt-get -y install /tmp/wkhtmltopdf.deb && \
    rm /tmp/wkhtmltopdf.deb && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install postgresql-client-17 && \
    apt-get -y upgrade && \
    rm -rf /var/lib/apt/lists/*

RUN echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen && locale-gen

RUN groupadd -g ${ODOO_GID} odoo && \
    useradd -l -m -d ${ODOO_HOMEDIR} -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} odoo && \
    mkdir -p /etc/odoo && \
    chown -R odoo:odoo /etc/odoo /opt

USER odoo
RUN git clone https://github.com/OCA/OCB.git --depth 1 --branch 18.0 --single-branch /opt/odoo

USER root
RUN uv pip install --system --upgrade wheel && \
    uv pip install --system -r /opt/odoo/requirements.txt && \
    uv pip install --system /opt/odoo && \
    uv pip install --system \
    escpos \
    matplotlib \
    odfpy \
    openpyxl \
    pandas \
    pdf2image \
    pdfkit \
    pdfminer.six \
    phonenumbers \
    poppler-utils \
    psycopg2-binary \
    pudb \
    pyopenssl \
    pyotp \
    python-magic \
    scipy \
    sqlalchemy==1.3.24 \
    svglib \
    Unidecode && \
    python -m pip install --no-cache-dir git+https://github.com/OCA/openupgradelib.git@master

USER odoo
WORKDIR ${ODOO_HOMEDIR}
EXPOSE 8069 8071 8072
VOLUME ${ODOO_HOMEDIR}

COPY run.sh /run.sh
CMD /bin/bash /run.sh
