# Odoo 12 Dockerized

This is a dockerized Odoo 12 setup.

### Quick notes
Odoo user will run with UID 3328 and GID 3328: prepare your mapped folder with proper owner/rights.

To choose your admin_passwd you can declare it with the ADMIN_PASSWD environment variable.

If already using [Traefik](https://traefik.io/) and [Docker Compose](https://docs.docker.com/compose/), you can create your stack by adapting the sample docker-compose.override.yml
