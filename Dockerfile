FROM php:7-apache
MAINTAINER Arquivei

ENV DEBIAN_FRONTEND noninteractive
RUN echo "America/Sao_Paulo" > /etc/timezone \
    && dpkg-reconfigure tzdata \
    && export LC_ALL=en_US.UTF-8 \
    && export LANG=en_US.UTF-8

RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends curl software-properties-common \
        git zlib1g-dev libpq-dev libxml2-dev xmlstarlet libmcrypt-dev libxslt-dev wget cron libmagickwand-dev \
    && rm -rf /var/lib/apt/lists/*

# Installing PostgreSQL 9.5 Client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update -qq \
    && apt-get install -qqy --no-install-recommends postgresql-client-9.5

# Installing PGBouncer
RUN apt-get update \
    && apt-get upgrade -qqy \
    && apt-get install -qqy --no-install-recommends libtool automake libevent-dev \
    && git clone --recursive https://github.com/pgbouncer/pgbouncer.git \
    && cd pgbouncer \
    && ./autogen.sh && ./configure --disable-evdns \
    && make && make install \
    && useradd --no-create-home -U postgres \
    && mkdir /etc/pgbouncer /var/log/postgresql /var/run/postgresql \
    && chown postgres:postgres /etc/pgbouncer \
    && chown root:postgres /var/log/postgresql /var/run/postgresql \
    && chmod -R 1775 /var/log/postgresql /var/run/postgresql

RUN pecl install imagick && docker-php-ext-enable imagick
RUN docker-php-ext-install zip pdo_pgsql pdo_mysql soap mcrypt opcache xmlrpc xsl \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-jpeg-dir=/usr/lib/x86_64-linux-gnu --with-png-dir=/usr/lib/x86_64-linux-gnu --with-freetype-dir=/usr/lib/x86_64-linux-gnu \
    && docker-php-ext-install gd \
    && curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-5.4.0-amd64.deb \
    && dpkg -i filebeat-5.4.0-amd64.deb \
    && a2enmod headers cache rewrite headers expires \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer \
    && systemctl enable filebeat

RUN echo "export TERM=xterm" > /root/.bashrc
COPY ./php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./run.sh /run.sh
ENTRYPOINT ["bash", "/run.sh"]
