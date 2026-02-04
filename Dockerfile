FROM ubuntu:noble-20260113

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

ENV PYTHON_VERSION=3.12.12

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

COPY --from=ghcr.io/astral-sh/uv:0.9.29 /uv /uvx /bin/

RUN apt-get update && \
    curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-3/wkhtmltox_0.12.6.1-3.jammy_amd64.deb -o /tmp/wkhtmltopdf.deb && \
    apt-get -y install /tmp/wkhtmltopdf.deb && \
    rm /tmp/wkhtmltopdf.deb && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install postgresql-client-16 && \
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
    uv pip install --system /opt/odoo && \
    uv pip install --system \
    asn1crypto==1.5.1 \
    attrs==23.2.0 \
    Babel==2.10.3 \
    beautifulsoup4==4.12.3 \
    cached-property==1.5.2 \
    cbor2==5.6.2 \
    certifi==2023.11.17 \
    chardet==5.2.0 \
    charset-normalizer==3.3.2 \
    cryptography==41.0.7 \
    decorator==5.1.1 \
    defusedxml==0.7.1 \
    docopt==0.6.2 \
    docutils==0.18.1 \
    escpos \
    et-xmlfile==1.0.1 \
    freetype-py==2.4.0 \
    freezegun==1.2.1 \
    geoip2==2.9.0 \
    gevent==25.9.1 \
    greenlet==3.2.4 \
    idna==3.6 \
    isodate==0.6.1 \
    Jinja2==3.1.2 \
    libsass==0.22.0 \
    lxml-html-clean==0.1.1 \
    lxml==4.9.3 \
    MarkupSafe==2.1.5 \
    matplotlib \
    maxminddb==3.0.0 \
    num2words==0.5.13 \
    odoorpc \
    ofxparse==0.21 \
    openpyxl==3.1.2 \
    pandas \
    passlib==1.7.4 \
    pdf2image \
    pdfkit \
    pdfminer.six==20221105 \
    phonenumbers==8.12.57 \
    pillow==10.2.0 \
    platformdirs==4.2.0 \
    polib==1.1.1 \
    poppler-utils \
    psutil==5.9.8 \
    psycopg2-binary \
    psycopg2==2.9.9 \
    pudb \
    pyasn1-modules==0.2.8 \
    pyasn1==0.4.8 \
    pycairo==1.25.1 \
    pyOpenSSL==23.2.0 \
    pyotp \
    PyPDF2==2.12.1 \
    pyserial==3.5 \
    pysftp \
    python-dateutil==2.8.2 \
    python-ldap==3.4.4 \
    python-magic==0.4.27 \
    python-slugify==8.0.4 \
    python-stdnum==1.19 \
    pytz==2024.1 \
    pyusb==1.3.1 \
    PyYAML==6.0.1 \
    qrcode==7.4.2 \
    reportlab==4.1.0 \
    requests-file==1.5.1 \
    requests-toolbelt==1.0.0 \
    requests==2.31.0 \
    rjsmin==1.2.0 \
    rlPyCairo==0.3.0 \
    roman==3.3 \
    scipy \
    setuptools==68.1.2 \
    six==1.16.0 \
    soupsieve==2.5 \
    sqlalchemy==1.3.24 \
    svglib \
    typing_extensions==4.10.0 \
    Unidecode==1.3.8 \
    urllib3==2.0.7 \
    vobject==0.9.6.1 \
    watchdog==3.0.0 \
    Werkzeug==3.1.5 \
    wheel==0.42.0 \
    xlrd==2.0.1 \
    XlsxWriter==3.1.9 \
    xlwt==1.3.0 \
    zeep==4.2.1 \
    zope.event==5.0 \
    zope.interface==6.1 && \
    python -m pip install --no-cache-dir git+https://github.com/OCA/openupgradelib.git@master

USER odoo
WORKDIR ${ODOO_HOMEDIR}
EXPOSE 8069 8071 8072
VOLUME ${ODOO_HOMEDIR}

COPY run.sh /run.sh
CMD /bin/bash /run.sh
