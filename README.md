```
$ make docker
$ docker run --name build-profiler -it -d --privileged -p16686:16686 docker-build-profiler
$ docker exec -it build-profiler mkdir poc
$ docker cp . build-profiler:/workspace/poc
$ docker exec -it build-profiler ./init.sh
$ docker exec -it build-profiler /bin/buildkit/buildctl build --frontend=dockerfile.v0 --local context=poc --local dockerfile=poc
$ curl -s http://localhost:16686/api/traces\?service\=buildctl | jq '.'
```
