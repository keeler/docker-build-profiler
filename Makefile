IMAGE ?= docker-build-profiler
IMAGE_TAG ?= latest

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
	  --build-arg buildkit_version=$(BUILDKIT_VERSION) \
		--build-arg jaeger_version=$(JAEGER_VERSION) \
		-t $(IMAGE):$(IMAGE_TAG) .

.PHONY: run
run:
	docker run -it -d --privileged \
	  --name $(CONTAINER_NAME) \
		-p16686:16686 \
		$(IMAGE):$(IMAGE_TAG)

.PHONY: init
init:
	$(shell docker exec -i $(CONTAINER_NAME) ./init.sh &)

.PHONY: stop
stop:
	docker stop $(CONTAINER_NAME)
	docker rm $(CONTAINER_NAME)

.PHONY: clean
clean:
	rm -rf jaeger/

.PHONY: docker.clean
docker.clean:
	docker rmi -f $(IMAGE):$(IMAGE_TAG)
