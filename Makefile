IMAGE ?= docker-build-profiler
IMAGE_TAG ?= latest

.PHONY: docker
docker:
	docker build -t $(IMAGE):$(IMAGE_TAG) .
