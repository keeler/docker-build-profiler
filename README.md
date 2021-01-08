# docker-build-profiler

[![](https://img.shields.io/badge/dockerhub-keelerrussell%2Fdocker--build--profiler-blue)](https://hub.docker.com/r/keelerrussell/docker-build-profiler)

A docker image which uses docker-in-docker + buildkit + Jaeger to profile docker build times.

## Background

Inspired by this PR: https://github.com/moby/buildkit/pull/255

Read more about it here: https://keeler.github.io/docker-build-profiling/

## Developing

The basic idea is to start with a docker-in-docker image and install buildkit into it.
It also installs Jaeger into the image, but as a gzipped file which gets loaded at container start time.

The Makefile automates basically everything:

- `make` or `make docker` - build the docker image.
- `make run` - run the image as a detatched container.
- `make logs` - view logs of the running container.
- `make shell` - get a `/bin/sh` into the running container.
- `make stop` - stop the running container.
