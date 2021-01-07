```
$ make docker
$ make run
$ make init
$ docker exec -it build-profiler mkdir poc
$ docker cp . build-profiler:/workspace/poc
$ docker exec -it build-profiler buildctl build \
  --frontend=dockerfile.v0 \
  --local context=poc \
  --local dockerfile=poc
$ curl -s http://localhost:16686/api/traces\?service\=buildctl | jq '.'
```
