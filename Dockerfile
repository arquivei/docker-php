FROM php:7.0-apache
MAINTAINER Arquivei

ENV DEBIAN_FRONTEND noninteractive

RUN export LC_ALL=en_US.UTF-8 \
    && export LANG=en_US.UTF-8

RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends curl software-properties-common \
        zlib1g-dev libpq-dev postgresql-client \
        libmcrypt-dev libxslt-dev wget

COPY ./php.ini /usr/local/etc/php/conf.d/php.ini

RUN docker-php-ext-install zip pdo_pgsql soap mcrypt opcache xmlrpc xsl \
    && curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.2.3_amd64.deb \
    && dpkg -i filebeat_1.2.3_amd64.deb \
    && a2enmod headers cache rewrite headers expires \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

RUN echo "export TERM=xterm" > /root/.bashrc
COPY ./run.sh /run.sh
ENTRYPOINT ["bash", "/run.sh"]
