# docker-php

Docker PHP based on PHP:8.0

## Installed Packages

* zip
* soap
* bcmath
* pgsql
* pdo_pgsql
* pdo_mysql
* grpc
* redis
* rdkafka

## Warning

The `protobuf` extension does not have an official release with php 8 support yet. If you 
depend on any GCP service, the latency with such services may increase.

As soon as PHP 8 support is added we will update this image.
