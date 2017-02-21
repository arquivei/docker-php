FROM php:7-apache
MAINTAINER Arquivei

ENV DEBIAN_FRONTEND noninteractive

RUN export LC_ALL=en_US.UTF-8 \
    && export LANG=en_US.UTF-8

RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends curl software-properties-common \
        git zlib1g-dev libpq-dev postgresql-client \
        libxml2-dev xmlstarlet libmcrypt-dev libxslt-dev wget cron

# Installing PGBouncer
RUN apt-get update \
    && apt-get install -qqy --no-install-recommends libtool automake libevent-dev \
    && git clone https://github.com/pgbouncer/pgbouncer.git \
    && cd pgbouncer \
    && git submodule init && git submodule update \
    && ./autogen.sh && ./configure --disable-evdns \
    && make && make install \
    && useradd --no-create-home -U postgres \
    && mkdir /etc/pgbouncer \
    && chown -R postgres:postgres /etc/pgbouncer \
    && mkdir /var/log/postgresql \
    && mkdir /var/run/postgresql \
    && chown root:postgres /var/log/postgresql \
    && chown root:postgres /var/run/postgresql \
    && chmod -R 1775 /var/log/postgresql \
    && chmod -R 1775 /var/run/postgresql

RUN apt-get update \
    && apt-get install -y --no-install-recommends libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*
COPY ./php.ini /usr/local/etc/php/conf.d/php.ini

RUN pecl install imagick && docker-php-ext-enable imagick
RUN docker-php-ext-install zip pdo_pgsql pdo_mysql soap mcrypt opcache xmlrpc xsl \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-jpeg-dir=/usr/lib/x86_64-linux-gnu --with-png-dir=/usr/lib/x86_64-linux-gnu --with-freetype-dir=/usr/lib/x86_64-linux-gnu \
    && docker-php-ext-install gd \
    && curl -L -O https://download.elastic.co/beats/filebeat/filebeat_1.2.3_amd64.deb \
    && dpkg -i filebeat_1.2.3_amd64.deb \
    && a2enmod headers cache rewrite headers expires \
    && chown -R postgres:postgres /etc/pgbouncer \
    && chown root:postgres /var/log/postgresql \
    && chmod -R 1775 /var/log/postgresql \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer \
    && systemctl enable filebeat

RUN echo "export TERM=xterm" > /root/.bashrc
COPY ./run.sh /run.sh
ENTRYPOINT ["bash", "/run.sh"]
