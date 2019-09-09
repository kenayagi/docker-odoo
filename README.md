# Odoo 10 Dockerized

This is a dockerized Odoo 10 setup.

It needs an external container for DB and a single volume for persistent data.

Quick notes:
Odoo user will run with UID 105 and GID 109: prepare your volume with proper owner/rights.
To choose your admin_passwd you can declare it with the ADMIN_PASSWD environment variable.
If already using [Traefik](https://traefik.io/) and [Docker Compose](https://docs.docker.com/compose/), you can create the stack with something like:


```
version: "2"

services:
  app:
    image: kenayagi/odoo:10.0
    restart: always
    volumes:
      - /srv/odoodata/installationid:/var/lib/odoo
    networks:
      - traefik
      - net
    depends_on:
      - db
    environment:
      - TZ=Europe/Rome
      - POSTGRES_HOST=db
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=PassWooorD
      - ODOO_DATADIR=/var/lib/odoo
      - ODOO_CONF=/var/lib/odoo/odoo.conf
      - REQ_FILE=/var/lib/odoo/requirements.txt
      - ADMIN_PASSWD=Db4dm1nSup3rS3cr3tP4ssw0rD
    labels:
      - traefik.enable=true
      - traefik.f.port=8069
      - traefik.f.frontend.rule=Host:odoo.domain.com
      - traefik.f.frontend.redirect.entryPoint=https
      - traefik.m.port=8069
      - traefik.m.frontend.rule=Host:odoo.domain.com;Path:/web/database/manager
      - traefik.m.frontend.redirect.entryPoint=https
      - traefik.m.frontend.whiteList.sourceRange=192.168.1.0/24
      - traefik.p.port=8072
      - traefik.p.frontend.rule=Host:odoo.domain.com;PathPrefix:/longpolling
      - traefik.p.frontend.redirect.entryPoint=https
      
  db:
    image: postgres:11.5
    command: -c "synchronous_commit=off" -c "full_page_writes=off" # Useful when based on ZFS
    restart: always
    volumes:
      - /srv/postgres/installationid:/var/lib/postgresql/data
    networks:
      - net
    environment:
      - TZ=Europe/Rome
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=PassWooorD
      
networks:
  net:
  traefik:
    external:
      name: traefik
```

