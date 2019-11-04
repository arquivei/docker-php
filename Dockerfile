FROM php:7.1-apache

LABEL maintainer="Engenharia Arquivei <engenharia@arquivei.com.br>"

ARG DEFAULT_TIMEZONE="America/Sao_Paulo"
ENV DEBIAN_FRONTEND noninteractive

RUN ln -fs /usr/share/zoneinfo/${DEFAULT_TIMEZONE} /etc/localtime \
    && dpkg-reconfigure -f noninteractive tzdata

RUN apt-get update -qq \
    && apt-get install -qqy --no-install-recommends curl software-properties-common git libssl-dev zlib1g-dev libpq-dev \
        libxml2-dev xmlstarlet libmcrypt-dev libxslt-dev wget cron libmagickwand-dev pgbouncer \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /tmp/librdkafka \
    && cd /tmp/librdkafka \
    && curl -L https://github.com/edenhill/librdkafka/archive/v1.1.0.tar.gz | tar xz \
    && cd librdkafka-1.1.0 \
    && ./configure \
    && make \
    && make install \
    && pecl install rdkafka-3.1.2 \
    && docker-php-ext-enable rdkafka \
    && rm -rf /tmp/librdkafka

RUN pecl install imagick && docker-php-ext-enable imagick \
    && pecl install ds && docker-php-ext-enable ds
RUN docker-php-ext-install zip pdo_pgsql pdo_mysql soap opcache xmlrpc xsl bcmath \
    && docker-php-ext-configure gd --enable-gd-native-ttf --with-jpeg-dir=/usr/lib/x86_64-linux-gnu \
        --with-png-dir=/usr/lib/x86_64-linux-gnu --with-freetype-dir=/usr/lib/x86_64-linux-gnu \
    && docker-php-ext-install gd \
    && curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.6.1-amd64.deb \
    && dpkg -i filebeat-6.6.1-amd64.deb \
    && a2enmod headers cache rewrite headers expires \
    && curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer \
    && update-rc.d filebeat defaults

RUN echo "export TERM=xterm" > /root/.bashrc
COPY ./php.ini /usr/local/etc/php/conf.d/php.ini
COPY ./openssl.cnf /etc/ssl/openssl.cnf
COPY ./run.sh /run.sh
ENTRYPOINT ["bash", "/run.sh"]
