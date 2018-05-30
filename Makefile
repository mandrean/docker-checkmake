CHECKMAKE_VERSION ?= 28d3860

# Image and binary can be overidden with env vars.
DOCKER_IMAGE ?= mandrean/checkmake

# Get the current commit hash
GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))
GIT_REMOTE_URL = $(shell git config --get remote.origin.url)
DATE = $(shell date +"%Y%m%d%H%M%S")

ifndef CHECKMAKE_VERSION
$(error You need to specify the Checkmake CHECKMAKE_VERSION)
endif

# Find out if the working directory is clean
GIT_NOT_CLEAN_CHECK = $(shell git status --porcelain)
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
DOCKER_TAG_SUFFIX = "-dirty"
endif

# Don't push to Docker Hub if this isn't a clean repo
ifneq (x$(GIT_NOT_CLEAN_CHECK), x)
$(error echo You are trying to release a build based on a dirty repo!)
endif

# Add the commit ref for development builds. Mark as dirty if the working directory isn't clean
DOCKER_TAG = $(CHECKMAKE_VERSION)-$(GIT_COMMIT)$(DOCKER_TAG_SUFFIX)

docker_clean:
	docker rmi -f $(shell docker images $(DOCKER_IMAGE) -q | uniq)

# Lint Docker image with Hadolint https://github.com/hadolint/hadolint
docker_lint:
	docker run --rm -v "${PWD}:/home" -w /home hadolint/hadolint:v1.6.6 hadolint --ignore DL4001 Dockerfile*

docker_build:
	docker build \
		--build-arg CHECKMAKE_VERSION=$(CHECKMAKE_VERSION) \
		--build-arg BUILD_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ") \
		--build-arg VERSION=$(CHECKMAKE_VERSION) \
		--build-arg VCS_URL=$(GIT_REMOTE_URL) \
		--build-arg VCS_REF=$(GIT_COMMIT) \
		-t $(DOCKER_IMAGE):$(DOCKER_TAG) \
		.

docker_tag:
	@echo $(DOCKER_TAG)

docker_push:
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

docker_release: docker_push
	# Also tag image latest and Checkmake version
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):latest
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(DOCKER_IMAGE):$(CHECKMAKE_VERSION)
	docker push $(DOCKER_IMAGE):latest
	docker push $(DOCKER_IMAGE):$(CHECKMAKE_VERSION)

makefile_lint:
	docker run --rm -v "${PWD}:/work" -w /work mandrean/checkmake:28d3860 Makefile

shell_lint:
	docker run --rm -v "${PWD}:/mnt" -w /mnt koalaman/shellcheck:v0.4.7 **/*.sh

.PHONY: docker_clean docker_lint docker_build docker_tag docker_push docker_release makefile_lint shell_lint
