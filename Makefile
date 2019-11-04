BASE_NAME := arquivei/php
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH := $(shell git rev-parse HEAD)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container
build: build-apache build-cli build-fpm

build-nc: build-nc-apache build-nc-cli build-nc-fpm

build-cli-alpine:
	docker build -t $(BASE_NAME):$(GIT_BRANCH)-cli-alpine -f cli/alpine.Dockerfile ./cli

build-cli-debian:
	docker build -t $(BASE_NAME):$(GIT_BRANCH)-cli-debian -f cli/debian.Dockerfile ./cli

build-fpm-alpine:
	docker build -t $(BASE_NAME):$(GIT_BRANCH)-fpm-alpine -f fpm/alpine.Dockerfile ./fpm

build-fpm-debian:
	docker build -t $(BASE_NAME):$(GIT_BRANCH)-fpm-debian -f fpm/debian.Dockerfile ./fpm

build-apache:
	docker build -t $(BASE_NAME):$(GIT_BRANCH)-apache -f apache/Dockerfile ./apache

build-cli: build-cli-alpine build-cli-debian
build-fpm: build-fpm-alpine build-fpm-debian

build-nc-cli-alpine:
	docker build --no-cache -t $(BASE_NAME):$(GIT_BRANCH)-cli-alpine -f cli/alpine.Dockerfile ./cli

build-nc-cli-debian:
	docker build --no-cache -t $(BASE_NAME):$(GIT_BRANCH)-cli-debian -f cli/debian.Dockerfile ./cli

build-nc-fpm-alpine:
	docker build --no-cache -t $(BASE_NAME):$(GIT_BRANCH)-fpm-alpine -f fpm/alpine.Dockerfile ./fpm

build-nc-fpm-debian:
	docker build --no-cache -t $(BASE_NAME):$(GIT_BRANCH)-fpm-debian -f fpm/debian.Dockerfile ./fpm

build-nc-apache:
	docker build --no-cache -t $(BASE_NAME):$(GIT_BRANCH)-apache -f apache/Dockerfile ./apache

build-nc-cli: build-nc-cli-alpine build-nc-cli-debian
build-nc-fpm: build-nc-fpm-alpine build-nc-fpm-debian
