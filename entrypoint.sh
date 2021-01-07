#!/bin/sh
# Start Jaeger and buildkit daemon.

# Entrypoint of parent image.
exec /usr/local/bin/dockerd-entrypoint.sh "$@" &

while ! pgrep -f dockerd
do
  echo "Waiting for dockerd up..."
  sleep 1
done

while ! pgrep -f containerd
do
  echo "Waiting for containerd up..."
  sleep 1
done

echo "Unpacking Jaeger docker image..."
docker load --input /etc/self/jaeger.tar.gz

echo "Starting Jaeger..."
docker run -d -p6831:6831/udp -p16686:16686 $JAEGER_IMAGE

echo "Starting buildkit daemon..."
buildkitd
