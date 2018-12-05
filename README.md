# Unofficial Odoo 10 for Docker

Dockerized Odoo 10.
Based on OCB, Italian OCA and some other addons repo.

It needs an external container for DB and some mapped folders for persistent data.

Create the odoo.conf file containing your Odoo DB admin password:

```
[options]
admin_passwd = MyOdooDBAdminSuperSecretPassword
```


If already using traefik, you can launch through docker-compose with something like:
```
version: 2

services:
  odoo-db:
    restart: unless-stopped
    image: postgres:10.6-alpine
    networks:
      odoo:
        aliases:
          - odoo-db
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

  odoo-app:
    restart: unless-stopped
    image: kenayagi/odoo
    depends_on:
      - odoo-db
    environment:
      - POSTGRES_HOST=odoo-db
      - POSTGRES_USER=odoo
      - POSTGRES_PASSWORD=DBUserPassword
      - TZ='Europe/Rome'
    expose:
      - 8069
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
      - traefik.frontend.rule=Host:odoo.yourdomain.com
      - traefik.frontend.redirect.entryPoint=https
      - traefik.port=8069
      - traefik.backend=odoo
      - traefik.docker.network=traefik
      
networks:
  odoo:
  traefik:
    external:
      name: traefik
```
