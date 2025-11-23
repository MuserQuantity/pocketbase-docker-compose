FROM alpine:3 AS downloader

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION=0.23.0

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"

RUN apk add --no-cache unzip wget \
    && wget https://github.com/pocketbase/pocketbase/releases/download/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && unzip pocketbase_${VERSION}_${BUILDX_ARCH}.zip \
    && chmod +x /pocketbase

FROM alpine:3
RUN apk add --no-cache ca-certificates tzdata wget

WORKDIR /

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
