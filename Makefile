BASE_NAME := arquivei/php
GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
GIT_HASH := $(shell git rev-parse HEAD)

# Dockerfile libs versions:
RDKAFKA_VERSION ?= "1.1.0"
RDKAFKA_PECL_VERSION ?= "3.1.2"

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: require-% help
# This target was created inspired by this stackoverflow question:
# https://stackoverflow.com/questions/4728810/makefile-variable-as-prerequisite/35845931
require-%: ## Requires that a specific variable is defined, example require-MYVAR
	@ if [ "${${*}}" = "" ]; then \
		echo "Environment variable $* not set"; \
		exit 1; \
	fi

build-latest:
	@ if [ ! -f $(CUSTOM_VERSION)/$(CUSTOM_OS).Dockerfile ]; then \
		echo "Could not find dockerfile: $(CUSTOM_VERSION)/$(CUSTOM_OS).Dockerfile"; \
		exit 1; \
	fi
	docker build \
		--file $(CUSTOM_VERSION)/$(CUSTOM_OS).Dockerfile \
		--tag $(BASE_NAME):$(GIT_BRANCH)-$(CUSTOM_VERSION)-$(CUSTOM_OS) \
		./$(CUSTOM_VERSION)

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
# Build the container
build: build-cli build-fpm ## Builds all possible images
build-cli: build-cli-alpine build-cli-debian ## Builds only the CLI based images
build-fpm: build-fpm-alpine build-fpm-debian ## Builds only the FPM based images

build-cli-alpine: ## Builds the CLI in Alpine version
	CUSTOM_OS=alpine CUSTOM_VERSION=cli $(MAKE) build-latest

build-cli-debian: ## Builds the CLI in Debian version
	CUSTOM_OS=debian CUSTOM_VERSION=cli $(MAKE) build-latest

build-fpm-alpine: ## Builds the FPM in Alpine version
	CUSTOM_OS=alpine CUSTOM_VERSION=fpm $(MAKE) build-latest

build-fpm-debian: ## Builds the FPM in Debian version
	CUSTOM_OS=debian CUSTOM_VERSION=fpm $(MAKE) build-latest

build-custom: ## Creates a custom build of CUSTOM_VERSION=(cli|fpm), CUSTOM_OS=(alpine|debian) AND desired versions of: RDKAFKA_VERSION AND RDKAFKA_PECL_VERSION
	@ if [ ! -f $(CUSTOM_VERSION)/$(CUSTOM_OS).Dockerfile ]; then \
		echo "Could not find dockerfile: $(CUSTOM_VERSION)/$(CUSTOM_OS).Dockerfile"; \
		exit 1; \
	fi
	docker build \
		--build-arg RDKAFKA_VERSION=$(RDKAFKA_VERSION) \
		--build-arg RDKAFKA_PECL_VERSION=$(RDKAFKA_PECL_VERSION) \
		--file $(CUSTOM_VERSION)/$(CUSTOM_OS).Dockerfile \
		--tag $(BASE_NAME):$(GIT_BRANCH)-$(CUSTOM_VERSION)-$(CUSTOM_OS)-rd-$(RDKAFKA_VERSION)-lib-$(RDKAFKA_PECL_VERSION) \
		./$(CUSTOM_VERSION)

publish-custom: build-custom ## Builds and publish the custom version