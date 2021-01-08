ARG dind_version

FROM docker:${dind_version}-dind

ARG buildkit_version
ARG jaeger_version

RUN test -n "$buildkit_version" || (echo "buildkit_version arg not set" && exit 5)
RUN test -n "$jaeger_version" || (echo "jaeger_version arg not set" && exit 5)

WORKDIR /etc/self

# Download and install buildkit
ENV BUILDKIT_VERSION=${buildkit_version}
ENV BUILDKIT_ARCHIVE=buildkit-v$BUILDKIT_VERSION.linux-amd64.tar.gz
RUN wget https://github.com/moby/buildkit/releases/download/v$BUILDKIT_VERSION/$BUILDKIT_ARCHIVE
RUN tar xvzf $BUILDKIT_ARCHIVE \
 && mkdir /bin/buildkit \
 && mv ./bin/* /bin/buildkit \
 && rm -rf ./bin $BUILDKIT_ARCHIVE
ENV PATH="${PATH}:/bin/buildkit"

# Set up Jaeger and buildkit daemon to run.
# See https://github.com/moby/buildkit/pull/255
ENV JAEGER_VERSION=${jaeger_version}
ENV JAEGER_IMAGE=jaegertracing/all-in-one:${JAEGER_VERSION}
ENV JAEGER_TRACE=0.0.0.0:6831

# This folder has an unzipped "docker save"-d version of Jaeger.
# Compress with tar here to avoid magic number errors due to different tar versions.
ADD ./jaeger ./jaeger
RUN tar czvf jaeger.tar.gz -C jaeger/ .
RUN rm -rf ./jaeger

ADD entrypoint.sh entrypoint.sh
ENTRYPOINT ["/etc/self/entrypoint.sh"]

# Empty dir for users to put docker build contexts.
WORKDIR /workspace
