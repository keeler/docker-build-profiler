NAMESPACE ?= keelerrussell
IMAGE ?= docker-build-profiler
REMOTE_IMAGE ?= $(NAMESPACE)/$(IMAGE)
IMAGE_TAG ?= latest
IMAGE_VERSION ?= dind_$(DIND_VERSION)-buildkit_$(BUILDKIT_VERSION)-jaeger_$(JAEGER_VERSION)

DIND_VERSION ?= 20.10.2
BUILDKIT_VERSION ?= 0.8.0
JAEGER_VERSION ?= 1.21.0

JAEGER_IMAGE = jaegertracing/all-in-one:$(JAEGER_VERSION)
CONTAINER_NAME = build-profiler

.PHONY: docker
docker: clean
	docker pull $(JAEGER_IMAGE)
	mkdir jaeger
	docker save $(JAEGER_IMAGE) | tar xv -C jaeger
	docker build \
	  --build-arg dind_version=$(DIND_VERSION) \
	  --build-arg buildkit_version=$(BUILDKIT_VERSION) \
		--build-arg jaeger_version=$(JAEGER_VERSION) \
		-t $(IMAGE):$(IMAGE_TAG) .

.PHONY: run
run:
	docker run -it -d --privileged \
	  --name $(CONTAINER_NAME) \
		-p16686:16686 \
		$(IMAGE):$(IMAGE_TAG)

.PHONY: logs
logs:
	docker logs -f $(CONTAINER_NAME)

.PHONY: shell
shell:
	docker exec -it $(CONTAINER_NAME) /bin/sh

.PHONY: stop
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

.PHONY: clean
clean:
	rm -rf jaeger/

.PHONY: docker.clean
docker.clean:
	docker rmi -f $$(docker images $(IMAGE))
	docker rmi -f $$(docker images $(REMOTE_IMAGE))

.PHONY: tag.docker
tag.docker: docker
	docker tag $(IMAGE):$(IMAGE_TAG) $(IMAGE):$(IMAGE_VERSION)
	docker tag $(IMAGE):$(IMAGE_TAG) $(REMOTE_IMAGE):$(IMAGE_TAG)
	docker tag $(IMAGE):$(IMAGE_TAG) $(REMOTE_IMAGE):$(IMAGE_VERSION)

.PHONY: docker.images
docker.images:
	@docker images $(IMAGE) --format="{{.Repository}}:{{.Tag}}"
	@docker images $(REMOTE_IMAGE) --format="{{.Repository}}:{{.Tag}}"

.PHONY: push
push: docker tag.docker
	docker push $(REMOTE_IMAGE):$(IMAGE_TAG)
	docker push $(REMOTE_IMAGE):$(IMAGE_VERSION)
