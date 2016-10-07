FROM php:5.6-apache
MAINTAINER Arquivei

ENV DEBIAN_FRONTEND noninteractive

RUN export LC_ALL=en_US.UTF-8 \
    && export LANG=en_US.UTF-8

RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends curl software-properties-common \
        git zlib1g-dev libpq-dev postgresql-client pgbouncer \
        libxml2-dev xmlstarlet libmcrypt-dev libxslt-dev wget

RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

RUN pecl install imagick && docker-php-ext-enable imagick
RUN docker-php-ext-install zip pdo_pgsql soap mcrypt opcache xmlrpc xsl \
    && curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.2.3_amd64.deb \
    && dpkg -i filebeat_1.2.3_amd64.deb \
    && a2enmod headers cache rewrite headers expires \
    && chown -R postgres:postgres /etc/pgbouncer \
    && chown root:postgres /var/log/postgresql \
    && chmod -R 1775 /var/log/postgresql \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN echo "export TERM=xterm" > /root/.bashrc
COPY ./run.sh /run.sh
ENTRYPOINT ["bash", "/run.sh"]
