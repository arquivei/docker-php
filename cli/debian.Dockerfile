FROM php:7.4-cli

LABEL maintainer="Engenharia Arquivei <engenharia@arquivei.com.br>"
ARG RDKAFKA_VERSION="1.5.3"
ARG RDKAFKA_PECL_VERSION="4.0.4"

RUN apt-get update \
    && apt-get -y install git libzip-dev libxml2-dev unzip libpq-dev \
    && docker-php-ext-install zip soap bcmath pgsql pdo_pgsql pdo_mysql

RUN pecl install grpc && docker-php-ext-enable grpc \
    && pecl install protobuf && docker-php-ext-enable protobuf \
    && pecl install redis && docker-php-ext-enable redis

#installing kafka
RUN mkdir -p /tmp/librdkafka \
    && cd /tmp \
    && curl -L https://github.com/edenhill/librdkafka/archive/v${RDKAFKA_VERSION}.tar.gz | tar xz -C /tmp/librdkafka --strip-components=1 \
    && cd librdkafka \
    && ./configure \
    && make \
    && make install \
    && pecl install rdkafka-${RDKAFKA_PECL_VERSION} \
    && docker-php-ext-enable rdkafka \
    && rm -rf /tmp/librdkafka
