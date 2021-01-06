FROM docker:dind

WORKDIR /workspace

ENV BUILDKIT_VERSION=0.8.0
ENV BUILDKIT_ARCHIVE=buildkit-v$BUILDKIT_VERSION.linux-amd64.tar.gz

# Download and install buildkit
RUN wget https://github.com/moby/buildkit/releases/download/v$BUILDKIT_VERSION/$BUILDKIT_ARCHIVE
RUN tar xvzf $BUILDKIT_ARCHIVE \
 && mkdir /bin/buildkit \
 && mv ./bin/* /bin/buildkit \
 && rm -rf ./bin $BUILDKIT_ARCHIVE

# Set up Jaeger and buildkit daemon to run.
# See https://github.com/moby/buildkit/pull/255
ENV JAEGER_IMAGE=jaegertracing/all-in-one:latest
ENV JAEGER_TRACE=0.0.0.0:6831

RUN printf '#!/bin/sh\n\
docker run -d -p6831:6831/udp -p16686:16686 $JAEGER_IMAGE\n\
/bin/buildkit/buildkitd &'\
>> init.sh
RUN chmod +x init.sh

