FROM ubuntu:jammy

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

COPY --from=ghcr.io/astral-sh/uv:0.9.8 /uv /uvx /bin/

RUN apt-get update && \
    curl -L https://github.com/wkhtmltopdf/packaging/releases/download/0.12.6.1-2/wkhtmltox_0.12.6.1-2.jammy_amd64.deb -o /tmp/wkhtmltopdf.deb && \
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
RUN git clone https://github.com/OCA/OCB.git --depth 1 --branch 16.0 --single-branch /opt/odoo

USER root
#RUN uv pip install --system -r /opt/odoo/requirements.txt
RUN uv pip install --system \
    Babel==2.9.1 \
    Jinja2==2.11.3 \
    MarkupSafe==1.1.1 \
    Pillow==9.0.1 \
    PyPDF2==1.26.0 \
    Werkzeug==2.0.2 \
    XlsxWriter==1.1.2 \
    appdirs==1.4.4 \
    attrs==25.4.0 \
    beautifulsoup4==4.14.2 \
    cached-property==2.0.1 \
    certifi==2025.10.5 \
    cffi==2.0.0 \
    chardet==4.0.0 \
    coverage==7.11.1 \
    cryptography==3.4.8 \
    decorator==4.4.2 \
    defusedxml==0.7.1 \
    docopt==0.6.2 \
    docutils==0.18.1 \
    ebaysdk==2.1.5 \
    freezegun==0.3.15 \
    gevent==22.10.2 \
    greenlet==2.0.2 \
    idna==2.10 \
    isodate==0.7.2 \
    libsass==0.20.1 \
    lxml==4.9.3 \
    num2words==0.5.9 \
    ofxparse==0.21 \
    packaging==25.0 \
    passlib==1.7.4 \
    polib==1.1.0 \
    psutil==5.8.0 \
    psycopg2==2.9.2 \
    pyOpenSSL==20.0.1 \
    pyasn1==0.6.1 \
    pyasn1_modules==0.4.2 \
    pycparser==2.23 \
    pydot==1.4.2 \
    pyparsing==3.2.5 \
    pyserial==3.5 \
    python-dateutil==2.8.1 \
    python-ldap==3.4.0 \
    python-stdnum==1.16 \
    pytz==2025.2 \
    pyusb==1.0.2 \
    qrcode==6.1 \
    reportlab==3.5.59 \
    requests-file==3.0.1 \
    requests-toolbelt==1.0.0 \
    requests==2.25.1 \
    six==1.17.0 \
    soupsieve==2.8 \
    typing_extensions==4.15.0 \
    urllib3==1.26.5 \
    vobject==0.9.6.1 \
    websocket-client==1.9.0 \
    xlrd==1.2.0 \
    xlwt==1.3.0 \
    zeep==4.0.0 \
    zope.event==6.1 \
    zope.interface==8.0.1

RUN uv pip install --system /opt/odoo
RUN uv pip install --system \
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
