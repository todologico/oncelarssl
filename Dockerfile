FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# user para correr artisan dentro del contenedor
ARG USER_NAME=appuser
ARG USER_UID=1000
RUN useradd -u $USER_UID -ms /bin/bash $USER_NAME
RUN usermod -aG 1000 $USER_NAME
RUN usermod -aG www-data $USER_NAME

RUN apt update

# basicos y php
RUN apt install -y software-properties-common unzip curl iproute2 iputils-ping nano supervisor htop git
RUN add-apt-repository -y ppa:ondrej/php
RUN apt update
RUN apt install -y php8.2-cli php8.2-fpm php8.2-common php8.2-mysql php8.2-pgsql php8.2-zip php8.2-gd php8.2-mbstring php8.2-curl php8.2-ldap php8.2-xml php8.2-bcmath
RUN mkdir -p /var/run/php

# nginx
RUN apt install -y nginx
RUN cd /etc/nginx/sites-available && rm *
RUN cd /etc/nginx/sites-enabled && rm *

# Instalación de Node.js 20.12.0 utilizando NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt update && apt install -y nodejs

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
COPY www.conf /etc/php/8.2/fpm/pool.d/

# nginx virtualhost 80 and 443
COPY ./virtualhost/nginx.conf /etc/nginx/
COPY ./virtualhost/virtualhost.conf /etc/nginx/conf.d/

# ssl certificate - private.pem (key)
COPY ./ssl/certificate.pem /etc/nginx/ssl/
COPY ./ssl/private.pem /etc/nginx/ssl/

COPY docker-entrypoint.sh /usr/local/bin/
COPY supervisord.conf /etc/

VOLUME /var/www/app

RUN chmod -R 755 /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]