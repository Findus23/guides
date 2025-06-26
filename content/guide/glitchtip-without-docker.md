---
title: "How to install GlitchTip without Docker"
date: 2021-01-29
categories: selfhosting
author: Lukas Winkler
cc_license: true
description: "A quick guide on how to install GlitchTip without Docker"
aliases:
- /books/how-to-install-glitchtip-without-docker
- /books/how-to-install-glitchtip-without-docker/page/prerequisites-93d
- /books/how-to-install-glitchtip-without-docker/page/basic-setup
- /books/how-to-install-glitchtip-without-docker/page/set-up-backend
- /books/how-to-install-glitchtip-without-docker/page/set-up-frontend
- /books/how-to-install-glitchtip-without-docker/page/set-up-gunicorn
- /books/how-to-install-glitchtip-without-docker/page/set-up-nginx
- /books/how-to-install-glitchtip-without-docker/page/set-up-celery
---

You like the error tracking sentry.io provides, you want to self-host it, but the setup takes up too many resources?
Then https://glitchtip.com/ might be something for you. It is a FOSS reimplementation of the sentry backend with most important features.
You can install it using docker following [their guide](https://glitchtip.com/documentation/install), but if you like me like to install things from stretch without docker, then this guide might be for you.

<!--more-->
## Prerequisites

- Python3
- [poetry](https://python-poetry.org/)
- Systemd (or something else to start services with)
- gunicorn (or something similar)
- nginx (or another webserver)
- PostgreSQL
- Redis

While I am using gunicorn and systemd services, there are many other ways to deploy a django application and this guide might still help as an inspiration.

This whole guide is more of a documentation of the way I set it up than a definitive guide on the one way to set up GlitchTip.

This guide was tested on 29-01-2021 on Debian stable using git hash 7d9de2949a5a38a8d1f98eeac0774db09be06e66

## Basic Setup

### Download Code

- create an empty directory for glitchtip somewhere (e.g. `/srv/server/glitchtip`)
- clone backend code: `git clone git@gitlab.com:glitchtip/glitchtip-backend.git code`


### Create a Virtualenv

If you use virtualenvwrapper something like `mkvirtualenv --python=python3 glitchtip` might work, otherwise you can create it with something like `python3 -m venv /path/to/new/virtual/environment`. Activate it (`workon glitchtip` or `source /path/to/new/virtual/environment/bin/activate`).

### Install dependencies

```bash
➜ cd code
➜ poetry install
➜ poetry remove uWSGI
➜ poetry add gunicorn
```

### Create Linux user
```bash
➜ sudo adduser glitchtip --disabled-login
```
### Create PostgreSQL user and database
```bash
➜ sudo -u postgres createuser glitchtip
➜ sudo -u postgres createdb -O glitchtip glitchtip
```

### Create runtime directory
(this is just a directory where the glitchtip user has write permission and can place all kinds of files)
```bash
➜ cd /srv/server/glitchtip
➜ mkdir runtime
```

## Set up backend


### Create environment variable file

```bash
➜ cd /srv/server/glitchtip
➜ nano env
```

```ini
DATABASE_URL="postgres://glitchtip@/glitchtip?host=/var/run/postgresql"
SECRET_KEY="some_randomly_generated_string"
REDIS_HOST=localhost
REDIS_DATABASE=13
EMAIL_URL="smtp://glitchtip@localhost"
DEFAULT_FROM_EMAIL="glitchtip@example.com"
GLITCHTIP_DOMAIN="https://bugs.example.com"
```

Don't forget to set the SECRET_KEY to a secret random string. This example assumes you have an SMTP server running on localhost and want to use Redis table 13.

Check [glitchtip.com/documentation/install#configuration](https://glitchtip.com/documentation/install#configuration) for more information about these options.


### Database migration 

All of the following commands assume they are run as `glitchtip` user, using the `python` binary from the virtualenv (`/path/to/new/virtual/environment/bin/python`) and have the above environment variables loaded.

One way to do this is to run
```bash
➜ sudo -u glitchtip bash
➜ export $(cat ../env | xargs) # repeat after editing env
➜ /srv/venv/glitchtip/bin/python manage.py THECOMMAND`
```



For the database migration run 
```bash
➜ python manage.py migrate
```

If you get any connection errors, check the `DATABASE_URL` above and if your PostgreSQL user exists.


## Set up Frontend

### Compile frontend

```bash
➜ cd /srv/server/glitchtip
➜ git clone https://gitlab.com/glitchtip/glitchtip-frontend.git frontend
➜ cd frontend
➜ npm install
➜ npm run build-prod
```

This should create a `dist` directory with the frontend.

Now go back to the backend and create a symlink:
```bash
➜ cd ../code
➜ ln -s ../frontend/dist/glitchtip-frontend/ dist
```



Afterwards create a code/static and code/media directory and change the owner to `glitchtip`. Finally run
```bash
➜ python manage.py collectstatic
```

### Quick test

You should now be able to run
```bash
➜ python manage.py runserver
```

And access glitchtip using the returned URL (assuming there is no firewall blocking that port. When in doubt forward the port using SSH.


## Set up Gunicorn

### Create a config file

```bash
➜ cd /srv/server/glitchtip
➜ nano gunicorn.py
```

```python
pidfile = "/srv/server/glitchtip/runtime/pid"
bind = "unix:/srv/server/glitchtip/runtime/socket"
proc_name = "glitchtip"
worker_tmp_dir = "/dev/shm"
workers = 3
```

Check the [gunicorn docs](https://docs.gunicorn.org/en/stable/) for more options and recommendations about the amount of workers.


### Create a gunicorn service

```bash
➜ sudoedit /etc/systemd/system/glitchtip.service
```

```ini
[Unit]
Description=glitchtip daemon
After=network.target

[Service]
PIDFile=/srv/server/glitchtip/runtime/pidfile
EnvironmentFile=/srv/server/glitchtip/env
User=glitchtip
Group=glitchtip
RuntimeDirectory=glitchtip
WorkingDirectory=/srv/server/glitchtip/code
ExecStart=/srv/venv/glitchtip/bin/gunicorn glitchtip.wsgi --config /srv/server/glitchtip/gunicorn.py
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID
PrivateTmp=true
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
➜ sudo systemctl daemon-reload
➜ sudo systemctl start glitchtip
➜ sudo journalctl -u glitchtip
➜ sudo systemctl enable glitchtip
```


## Set up Nginx


This depends a lot on your general Nginx setup, but there should be nothing special about this config file apart from redirecting API requests to gunicorn and static files to the `/static/` directory.

```bash
➜ sudoedit /etc/nginx/sites-available/glitchtip
```

```nginx
server {
        listen [::]:443 ssl http2;
        listen 443 ssl http2;
        server_name bugs.example.com;
        access_log /var/log/nginx/bugs.example.com.access.log;
        error_log /var/log/nginx/bugs.example.com.error.log;

        ssl_certificate /etc/letsencrypt/live/bugs.example.com/fullchain.pem;
        ssl_certificate_key /etc/letsencrypt/live/bugs.example.com/privkey.pem;

        add_header Strict-Transport-Security max-age=15768000;

        location ~ /\.git {
                deny all;
        }

        location / {
                alias /srv/server/glitchtip/code/static/;
                try_files $uri $uri/index.html /index.html;
                expires 1h;
                add_header Pragma public;
                add_header Cache-Control "public";
        }
        location /media/ {
                alias /srv/server/glitchtip/code/media/;
        }

        location ~ ^/(api|admin|_health|rest-auth)/ {
                proxy_pass         http://unix:/srv/server/glitchtip/runtime/socket;
                proxy_redirect     off;
                proxy_set_header   Host                 $host;
                proxy_set_header   X-Real-IP            $remote_addr;
                proxy_set_header   X-Forwarded-For      $proxy_add_x_forwarded_for;
                proxy_set_header   X-Forwarded-Proto    $scheme;
        }
}
```

```bash
➜ cd /etc/nginx/sites-enabled
➜ sudo ln -s ../sites-available/glitchtip
➜ sudo nginx -t && sudo service nginx reload
```

-----

Now you should be able to use GlitchTip without issues in your browser (create a user and afterwards log in). But to complete the setup we also need to set up celery.


## Set up Celery

### Set up Beat

```bash
➜ sudoedit /etc/systemd/system/glitchtip-celery-beat.service
```

```ini
[Unit]
Description=glitchtip celery beat
After=network.target

[Service]
EnvironmentFile=/srv/server/glitchtip/env
User=glitchtip
Group=glitchtip
RuntimeDirectory=glitchtip
WorkingDirectory=/srv/server/glitchtip/code
ExecStart=/srv/venv/glitchtip/bin/celery -A glitchtip beat -l info --pidfile=/srv/server/glitchtip/    runtime/celery-beat-pid --logfile=/srv/server/glitchtip/runtime/beat.log -s /srv/server/glitchtip/     runtime/celerybeat-schedule
PrivateTmp=true
Restart=always

[Install]
WantedBy=multi-user.target
```

### Set up one Worker

```bash
➜ sudoedit /etc/systemd/system/glitchtip-celery-worker.service
```

```ini
[Unit]
Description=glitchtip celery worker
After=network.target

[Service]
EnvironmentFile=/srv/server/glitchtip/env
User=glitchtip
Group=glitchtip
RuntimeDirectory=glitchtip
WorkingDirectory=/srv/server/glitchtip/code
ExecStart=/srv/venv/glitchtip/bin/celery -A glitchtip worker -l info --pidfile=/srv/server/glitchtip/  runtime/celery-worker-pid --logfile=/srv/server/glitchtip/runtime/worker.log
PrivateTmp=true
Restart=always

[Install]
WantedBy=multi-user.target
```


### start services

```bash
➜ sudo systemctl daemon-reload
➜ sudo systemctl start glitchtip-celery-worker.service
➜ sudo journalctl -u glitchtip-celery-worker
➜ sudo systemctl start glitchtip-celery-beat.service
➜ sudo journalctl -u glitchtip-celery-beat

➜ sudo systemctl enable glitchtip-celery-worker.service
➜ sudo systemctl enable glitchtip-celery-beat.service
```
