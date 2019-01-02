# Unofficial Odoo 10 for Docker

This is a dockerized Odoo 10 setup.
It's based on OCA/OCB with Italian localization and some other useful addons.

It needs an external container for DB and some mapped folders for persistent data.

Firstly create the odoo.conf file containing your Odoo DB admin password:

```

[options]
admin_passwd = MyOdooDBAdminSuperSecretPassword

```


Then, if already using [Traefik](https://traefik.io/) and [Docker Compose](https://docs.docker.com/compose/), you can create the stack with something like:


```

version: 2

services:
  db:
    restart: unless-stopped
    image: postgres:9.6-alpine
    networks:
      odoo:
        aliases:
          - db
    logging:
      driver: journald
    environment:
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=DBUserPassword
      - TZ='Europe/Rome'
    volumes:
      - /srv/docker/odoo/db/data:/var/lib/postgresql/data
    labels:
      - traefik.enable=false

  app:
    restart: unless-stopped
    image: kenayagi/odoo:2019.01.02.01
    depends_on:
      - db
    environment:
      - POSTGRES_HOST=db
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=DBUserPassword
      - TZ='Europe/Rome'
    expose:
      - 8069
      - 8072
    volumes:
      - /srv/docker/odoo/app/data:/srv/odoo
      - /srv/docker/odoo/app/odoo.conf:/srv/odoo.conf:ro
    logging:
      driver: journald
    networks:
      - traefik
      - odoo
    labels:
      - traefik.enable=true
      - traefik.odoo.port=8069
      - traefik.odoo.backend=odoo
      - traefik.odoo.frontend.rule=Host:odoo.yourdomain.com
      - traefik.odoo.frontend.redirect.entryPoint=https
      - traefik.odoolp.port=8072
      - traefik.odoolp.backend=odoo-lp
      - traefik.odoolp.frontend.rule=Host:odoo.yourdomain.com;PathPrefixStrip:/longpolling
      - traefik.odoolp.frontend.redirect.entryPoint=https
      - traefik.odoodm.frontend.rule=Host:odoo.yourdomain.com;Path:/web/database/manager
      - traefik.odoodm.frontend.redirect.entryPoint=https
      - traefik.odoodm.frontend.whiteList.sourceRange=192.168.1.0/16
      - traefik.odoodm.backend=odoo
      - traefik.docker.network=traefik
      
networks:
  odoo:
  traefik:
    external:
      name: traefik

```

