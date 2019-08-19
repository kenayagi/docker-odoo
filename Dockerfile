FROM debian:stretch

ARG ODOO_UID=105
ARG ODOO_GID=109

ENV ODOO_DATADIR=/var/lib/odoo
ENV ODOO_CONF=/var/lib/odoo/odoo.conf

ENV UPD_FILE=/var/lib/odoo/update.txt
ENV REQ_FILE=/var/lib/odoo/requirements.txt
ENV ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD
ENV POSTGRES_HOST=db
ENV POSTGRES_USER=odoo
ENV POSTGRES_PASSWORD=Us3rP4ssw0rD

RUN apt update && apt -y upgrade && apt -y install \
    build-essential \
    bzip2 \
    curl \
    geoip-database \
    git \
    gnupg \
    libgeoip1 \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libldap2-dev \
    libsasl2-dev \
    locales \
    nano \
    poppler-utils \
    procps \
    python \
    python-pip \
    python-setuptools \
    rsync \
    unzip \
    vim \
    wget

RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt -y install nodejs
RUN npm install -g less less-plugin-clean-css

RUN curl -L https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb -o /tmp/wkhtmltopdf.deb
RUN apt -y install /tmp/wkhtmltopdf.deb

RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ stretch-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN apt update && apt -y upgrade
RUN apt -y install postgresql-client-11

RUN apt clean
RUN rm -rf /var/lib/apt/lists/*

RUN echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
ENV LANG=it_IT.UTF-8

RUN groupadd -g ${ODOO_GID} odoo
RUN useradd -m -d /var/lib/odoo -s /bin/bash -u ${ODOO_UID} -g ${ODOO_GID} odoo
RUN mkdir -p /etc/odoo
RUN chown -R odoo:odoo /etc/odoo /opt

USER odoo
RUN git clone https://github.com/OCA/OCB.git --depth 1 --branch 10.0 --single-branch /opt/odoo

USER root
RUN pip install --upgrade pip
RUN pip install -r /opt/odoo/requirements.txt
RUN pip install -r /opt/odoo/doc/requirements.txt
RUN pip install /opt/odoo
RUN pip install Unidecode
RUN pip install git+https://github.com/OCA/openupgradelib.git@master

USER odoo
WORKDIR /var/lib/odoo

COPY odoo.conf /etc/odoo
COPY run.sh /run.sh

EXPOSE 8069 8071 8072

VOLUME /var/lib/odoo

CMD /bin/bash /run.sh
