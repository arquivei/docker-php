FROM arquivei/php:php7.2

MAINTAINER Arquivei

#installing kafka
RUN cd /tmp && mkdir librdkafka && cd librdkafka \
    && curl -L https://github.com/edenhill/librdkafka/archive/v0.11.6.tar.gz | tar xz \
    && cd librdkafka-0.11.6 \
    && ./configure && make && make install \
    && pecl install rdkafka

#add extension
RUN echo "\\n extension=rdkafka.so" >> /etc/php/7.2/lib/php-cli.ini
