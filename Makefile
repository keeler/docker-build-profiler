IMAGE ?= docker-build-profiler
IMAGE_TAG ?= latest

DIND_VERSION ?=
BUILDKIT_VERSION ?= 0.8.0
JAEGER_VERSION ?= 1.21.0

JAEGER_IMAGE = jaegertracing/all-in-one:$(JAEGER_VERSION)
JAEGER_ZIP = jaeger.tar.gz

.PHONY: docker
docker: clean
	docker pull $(JAEGER_IMAGE)
	mkdir jaeger
	docker save $(JAEGER_IMAGE) | tar xv -C jaeger
	# docker run --rm -it -v $$(pwd):/tmp docker:dind tar zcvf /tmp/jaeger.tar.gz -C /tmp/jaeger .
	docker build \
	  --build-arg buildkit_version=$(BUILDKIT_VERSION) \
		--build-arg jaeger_version=$(JAEGER_VERSION) \
		--build-arg jaeger_zip=$(JAEGER_ZIP) \
		-t $(IMAGE):$(IMAGE_TAG) .

.PHONY: run
run:
	docker run --name build-profiler -it -d --privileged -p16686:16686 docker-build-profiler

.PHONY: init
init:
	docker exec -it build-profiler ./init.sh

.PHONY: stop
stop:
	docker stop build-profiler
	docker rm build-profiler

.PHONY: clean
clean:
	rm -rf jaeger
	rm -f $(JAEGER_ZIP)