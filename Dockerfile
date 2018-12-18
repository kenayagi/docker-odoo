FROM debian:stretch

RUN apt update && apt -y upgrade

RUN apt -y install build-essential \
    curl \
    git \
    libxml2-dev \
    libxslt-dev \
    libzip-dev \
    libldap2-dev \
    libsasl2-dev \
    nano \
    postgresql-client-9.6 \
    python \
    python-pip \
    python-setuptools

RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt -y install nodejs
RUN npm install -g less less-plugin-clean-css

RUN curl -L https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb -o /tmp/wkhtmltopdf.deb
RUN apt -y install /tmp/wkhtmltopdf.deb

RUN mkdir -p /opt/odoo/core
RUN git clone https://github.com/OCA/OCB.git --depth 1 --branch 10.0 --single-branch /opt/odoo/core

RUN pip install --upgrade pip
RUN pip install -r /opt/odoo/core/requirements.txt
RUN pip install -r /opt/odoo/core/doc/requirements.txt
RUN pip install codicefiscale configparser evdev future pyXB==1.2.5 unidecode unicodecsv

RUN apt -y install locales
RUN echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
ENV LANG=it_IT.UTF-8

# Italian localization
RUN mkdir -p /opt/odoo/extra/l10n-italy
RUN git clone https://github.com/OCA/l10n-italy.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/l10n-italy

# Better ZIP Location and Partner first-last name separation
RUN mkdir -p /opt/odoo/extra/partner-contact
RUN git clone https://github.com/OCA/partner-contact.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/partner-contact

# Add Fiscal Year
RUN mkdir -p /opt/odoo/extra/account-financial-tools
RUN git clone https://github.com/OCA/account-financial-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-financial-tools

# Auto DB Backup
RUN mkdir -p /opt/odoo/extra/server-tools
RUN git clone https://github.com/OCA/server-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/server-tools
RUN pip install -r /opt/odoo/extra/server-tools/requirements.txt

# Recurring invoices
RUN mkdir -p /opt/odoo/extra/contract
RUN git clone https://github.com/OCA/contract.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/contract

RUN mkdir -p /srv/odoo
CMD /opt/odoo/core/odoo-bin --data-dir=/srv/odoo --config=/srv/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD --addons-path=/opt/odoo/core/addons,/opt/odoo/extra/l10n-italy,/opt/odoo/extra/partner-contact,/opt/odoo/extra/account-financial-tools,/opt/odoo/extra/server-tools,/opt/odoo/extra/contract
