FROM ubuntu:18.04
MAINTAINER Arquivei

ARG PHP_TZ="America/Sao_Paulo"
ENV DEBIAN_FRONTEND noninteractive

RUN echo $PHP_TZ > /etc/timezone \
    && export LC_ALL=en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && export LANGUAGE=en_US.UTF-8

#installing ubuntu common packages
RUN apt-get update \
    && apt-get -y --no-install-recommends install git ca-certificates tzdata autoconf \
    vim wget gcc build-essential libxml2-dev libssl-dev libcurl4-openssl-dev \
    pkg-config curl make libpq-dev libpspell-dev librecode-dev libcurl4-openssl-dev \
    libxft-dev libfreetype6-dev libpng-dev libjpeg62-dev

RUN dpkg-reconfigure tzdata

#installing php
RUN wget https://secure.php.net/distributions/php-7.2.11.tar.gz --no-check-certificate \
    && tar zxvf php-7.2.11.tar.gz && cd php-7.2.11 \
    && ./configure --prefix=/etc/php/7.2 \
        --with-config-file-scan-dir=/etc/php/7.2/php-fpm/conf.d/ \
        --bindir=/usr/bin \
        --sbindir=/usr/sbin \
        --enable-cli \
        --enable-debug \
        --enable-fpm \
        --enable-intl \
        --enable-json \
        --enable-mbstring \
        --enable-opcache \
        --enable-soap \
        --enable-xml \
        --enable-zip \
        --enable-bcmath \
        --enable-maintainer-zts \
        --with-tsrm-pthreads \
        --with-fpm-user=www-data \
        --with-fpm-group=www-data \
        --with-mysqli \
        --with-pgsql \
        --with-pdo-mysql \
        --with-pdo-pgsql \
        --with-curl \
        --with-openssl \
        --with-zlib \
        --with-gd \
        --with-jpeg-dir \
        --with-png-dir \
        --with-xmlrpc \
    && make && make install \
    && cp php.ini-production /etc/php/7.2/lib/php.ini \
    && cp php.ini-production /etc/php/7.2/lib/php-cli.ini \
    && rm -rf /application/php-7.2*

RUN cp /etc/php/7.2/etc/php-fpm.conf.default /etc/php/7.2/etc/php-fpm.conf

RUN apt-get update \
    && apt-get -y install autoconf php7.2-gd php-pear php-dev \
    && pecl install redis \
    && pecl install xdebug

#installing kafka
RUN cd /tmp && mkdir librdkafka && cd librdkafka \
    && curl -L https://github.com/edenhill/librdkafka/archive/v0.11.6.tar.gz | tar xz \
    && cd librdkafka-0.11.6 \
    && ./configure && make && make install \
    && pecl install rdkafka

#add extension
RUN mkdir /etc/php/7.2/php-fpm \
    && mkdir /etc/php/7.2/php-fpm/conf.d \
    && echo "extension=redis.so" > /etc/php/7.2/php-fpm/conf.d/redis.ini \
    && echo "zend_extension=xdebug.so" > /etc/php/7.2/php-fpm/conf.d/xdebug.ini \
    && echo "\\n extension=rdkafka.so" >> /etc/php/7.2/lib/php-cli.ini

#installing composer
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php -r "if (hash_file('SHA384', 'composer-setup.php') === '48e3236262b34d30969dca3c37281b3b4bbe3221bda826ac6a9a62d6444cdb0dcd0615698a5cbe587c3f0fe57a54d8f5') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');" \
    && mv /application/composer.phar /usr/bin/composer

#configuring php-fpm
COPY php-fpm/php-fpm-base.conf /etc/php/7.2/etc/php-fpm.d/z-overrides.conf
COPY ./entrypoint.sh /entrypoint.sh

ENTRYPOINT ["bash", "/entrypoint.sh"]
