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
    locales \
    nano \
    postgresql-client-9.6 \
    procps \
    python \
    python-pip \
    python-setuptools \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt -y install nodejs
RUN npm install -g less less-plugin-clean-css

RUN curl -L https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.stretch_amd64.deb -o /tmp/wkhtmltopdf.deb
RUN apt -y install /tmp/wkhtmltopdf.deb

RUN mkdir -p /srv/odoo

RUN echo "it_IT.UTF-8 UTF-8" > /etc/locale.gen
RUN locale-gen
ENV LANG=it_IT.UTF-8

# Crea utente di servizio
RUN groupadd -g 90 odoo
RUN useradd -m -d /opt/odoo -s /bin/bash -u 90 -g 90 odoo
RUN chown -R odoo:odoo /srv/odoo

USER odoo
WORKDIR /opt/odoo

# Core
RUN git clone https://github.com/OCA/OCB.git --depth 1 --branch 10.0 --single-branch /opt/odoo/core

# Prepara cartella per addons aggiuntivi
RUN mkdir -p /opt/odoo/extra

# Localizzazione italiana
RUN git clone https://github.com/OCA/l10n-italy.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/l10n-italy

# Migliorie CAP e province + separazione nome/cognome per partner
RUN git clone https://github.com/OCA/partner-contact.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/partner-contact

# Aggiunge anno fiscale ed utilità per contabilizzazione
RUN git clone https://github.com/OCA/account-financial-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-financial-tools

# Funzione DB Backup automatica
RUN git clone https://github.com/OCA/server-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/server-tools

# Contratti e fatture ricorrenti
RUN git clone https://github.com/OCA/contract.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/contract

# Aggiunge supporto per i DDT 
RUN git clone https://github.com/OCA/stock-logistics-workflow.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/stock-logistics-workflow

# Modalità di pagamento
RUN git clone https://github.com/OCA/account-payment.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-payment

# Migliorie webclient
RUN git clone https://github.com/OCA/web.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/web

# Funzioni aggiuntive per progetti
RUN git clone https://github.com/OCA/project.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/project

# Funzioni aggiuntive per fatturazione
RUN git clone https://github.com/OCA/account-invoicing.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-invoicing

# Utilità per attributi prodotto
RUN git clone https://github.com/OCA/product-attribute.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/product-attribute

# Commissioni
RUN git clone https://github.com/OCA/commission.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/commission

# Pagamenti bancari automatici
RUN git clone https://github.com/OCA/bank-payment.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/bank-payment

# Installazione dipendenze
USER root
RUN pip install --upgrade pip
RUN pip install -r /opt/odoo/core/requirements.txt
RUN pip install -r /opt/odoo/core/doc/requirements.txt
RUN pip install -r /opt/odoo/extra/server-tools/requirements.txt
RUN pip install codicefiscale configparser evdev future odooly pyXB==1.2.5 unidecode unicodecsv

# Imposta utente di esecuzione container
USER odoo
WORKDIR /opt/odoo

# Definisce comando di avvio
CMD /opt/odoo/core/odoo-bin --data-dir=/srv/odoo --config=/srv/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD --addons-path=/opt/odoo/core/addons,/opt/odoo/extra/l10n-italy,/opt/odoo/extra/partner-contact,/opt/odoo/extra/account-financial-tools,/opt/odoo/extra/server-tools,/opt/odoo/extra/contract,/opt/odoo/extra/stock-logistics-workflow,/opt/odoo/extra/account-payment,/opt/odoo/extra/web,/opt/odoo/extra/project,/opt/odoo/extra/account-invoicing,/opt/odoo/extra/product-attribute,/opt/odoo/extra/commission,/opt/odoo/extra/bank-payment
