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

RUN mkdir -p /opt/odoo/extra/l10n-italy
RUN git clone https://github.com/OCA/l10n-italy.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/l10n-italy

RUN mkdir -p /opt/odoo/extra/partner-contact
RUN git clone https://github.com/OCA/partner-contact.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/partner-contact

RUN mkdir -p /opt/odoo/extra/account-financial-tools
RUN git clone https://github.com/OCA/account-financial-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-financial-tools

RUN mkdir -p /opt/odoo/extra/server-tools
RUN git clone https://github.com/OCA/server-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/server-tools
RUN pip install -r /opt/odoo/extra/server-tools/requirements.txt

RUN mkdir -p /opt/odoo/extra/reporting-engine
RUN git clone https://github.com/OCA/reporting-engine.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/reporting-engine
RUN pip install -r /opt/odoo/extra/reporting-engine/requirements.txt

RUN mkdir -p /opt/odoo/extra/account-payment
RUN git clone https://github.com/OCA/account-payment.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-payment

RUN mkdir -p /opt/odoo/extra/stock-logistics-workflow
RUN git clone https://github.com/OCA/stock-logistics-workflow.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/stock-logistics-workflow

RUN mkdir -p /opt/odoo/extra/web
RUN git clone https://github.com/OCA/web.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/web

RUN mkdir -p /opt/odoo/extra/theme-ow
RUN git clone https://github.com/Openworx/backend_theme.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/theme-ow

RUN mkdir -p /opt/odoo/extra/contract
RUN git clone https://github.com/OCA/contract.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/contract

RUN mkdir -p /opt/odoo/extra/project
RUN git clone https://github.com/OCA/project.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/project

#RUN mkdir -p /opt/odoo/extra/bank-payment
#RUN git clone https://github.com/OCA/bank-payment.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/bank-payment

#RUN mkdir -p /opt/odoo/extra/account-invoicing
#RUN git clone https://github.com/OCA/account-invoicing.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-invoicing

#RUN mkdir -p /srv/odoo
#CMD /opt/odoo/core/odoo-bin --data-dir=/srv/odoo --config=/srv/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD --addons-path=/opt/odoo/core/addons,/opt/odoo/extra/l10n-italy,/opt/odoo/extra/partner-contact,/opt/odoo/extra/account-financial-tools,/opt/odoo/extra/server-tools,/opt/odoo/extra/reporting-engine,/opt/odoo/extra/account-payment,/opt/odoo/extra/stock-logistics-workflow,/opt/odoo/extra/web,/opt/odoo/extra/theme-ow,/opt/odoo/extra/contract,/opt/odoo/extra/project,/opt/odoo/extra/bank-payment,/opt/odoo/extra/account-invoicing

RUN mkdir -p /srv/odoo
CMD /opt/odoo/core/odoo-bin --data-dir=/srv/odoo --config=/srv/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD --addons-path=/opt/odoo/core/addons,/opt/odoo/extra/l10n-italy,/opt/odoo/extra/partner-contact,/opt/odoo/extra/account-financial-tools,/opt/odoo/extra/server-tools,/opt/odoo/extra/reporting-engine,/opt/odoo/extra/account-payment,/opt/odoo/extra/stock-logistics-workflow,/opt/odoo/extra/web,/opt/odoo/extra/theme-ow,/opt/odoo/extra/contract
