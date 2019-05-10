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

# Moduli personalizzati
RUN git clone https://github.com/kenayagi/odoo-modules.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/custom


# Aggiunge anno fiscale ed utilità per contabilizzazione
RUN git clone https://github.com/OCA/account-financial-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-financial-tools

# Regole per posizione fiscale
RUN git clone https://github.com/OCA/account-fiscal-rule.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-fiscal-rule

# Funzioni aggiuntive per fatturazione
RUN git clone https://github.com/OCA/account-invoicing.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-invoicing

# Modalità di pagamento
RUN git clone https://github.com/OCA/account-payment.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/account-payment

# Pagamenti bancari automatici
RUN git clone https://github.com/OCA/bank-payment.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/bank-payment

# Commissioni
RUN git clone https://github.com/OCA/commission.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/commission

# Contratti e fatture ricorrenti
RUN git clone https://github.com/OCA/contract.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/contract

# Personalizzazioni Efatto
RUN git clone https://github.com/efatto/efatto.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/efatto

# Localizzazione italiana
RUN git clone https://github.com/OCA/l10n-italy.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/l10n-italy

# Migliorie CAP e province + separazione nome/cognome per partner
RUN git clone https://github.com/OCA/partner-contact.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/partner-contact

# Punto vendita
RUN git clone https://github.com/OCA/pos.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/pos

# Utilità per attributi prodotto
RUN git clone https://github.com/OCA/product-attribute.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/product-attribute

# Funzioni aggiuntive per varianti prodotto
RUN git clone https://github.com/OCA/product-variant.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/product-variant

# Funzioni aggiuntive per progetti
RUN git clone https://github.com/OCA/project.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/project

# Funzioni aggiuntive per flusso acquisti
RUN git clone https://github.com/OCA/purchase-workflow.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/purchase-workflow

# Funzioni aggiuntive per asincronia
RUN git clone https://github.com/OCA/queue.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/queue

# Funzioni aggiuntive per vendite
RUN git clone https://github.com/OCA/sale-workflow.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/sale-workflow

# Funzione DB Backup automatica
RUN git clone https://github.com/OCA/server-tools.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/server-tools

# Migliori messaggistica
RUN git clone https://github.com/OCA/social.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/social

# Aggiunge supporto per i DDT 
RUN git clone https://github.com/OCA/stock-logistics-workflow.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/stock-logistics-workflow

# Migliorie webclient
RUN git clone https://github.com/OCA/web.git --depth 1 --branch 10.0 --single-branch /opt/odoo/extra/web


# Installazione dipendenze
USER root
RUN pip install --upgrade pip
RUN pip install -r /opt/odoo/core/requirements.txt
RUN pip install -r /opt/odoo/core/doc/requirements.txt
RUN pip install -r /opt/odoo/extra/pos/requirements.txt
RUN pip install -r /opt/odoo/extra/social/requirements.txt
RUN pip install -r /opt/odoo/extra/server-tools/requirements.txt
RUN pip install codicefiscale configparser erppeek evdev future odooly pyXB==1.2.6 unidecode unicodecsv validate_email

# Imposta utente di esecuzione container
USER odoo
WORKDIR /opt/odoo

# Definisce comando di avvio
CMD /opt/odoo/core/odoo-bin --data-dir=/srv/odoo --config=/srv/odoo.conf --db_host=$POSTGRES_HOST --db_user=$POSTGRES_USER --db_password=$POSTGRES_PASSWORD
