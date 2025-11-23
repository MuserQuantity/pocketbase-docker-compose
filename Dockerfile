FROM alpine:3 AS downloader

ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG VERSION
# Optional mirror for faster APK downloads in CN networks (e.g. https://mirrors.aliyun.com/alpine)
ARG ALPINE_MIRROR
# Optional GitHub proxy, e.g. https://mirror.ghproxy.com/https://github.com
ARG PB_DOWNLOAD_BASE="https://github.com/pocketbase/pocketbase/releases/download"

ENV BUILDX_ARCH="${TARGETOS:-linux}_${TARGETARCH:-amd64}${TARGETVARIANT}"

RUN if [ -n "${ALPINE_MIRROR}" ]; then \
        sed -i "s#https://dl-cdn.alpinelinux.org/alpine#${ALPINE_MIRROR}#g" /etc/apk/repositories; \
    fi \
    && apk add --no-cache unzip wget \
    && PB_URL="${PB_DOWNLOAD_BASE}/v${VERSION}/pocketbase_${VERSION}_${BUILDX_ARCH}.zip" \
    && wget -O pocketbase.zip "${PB_URL}" \
    && unzip pocketbase.zip \
    && chmod +x /pocketbase

FROM alpine:3
ARG ALPINE_MIRROR

RUN if [ -n "${ALPINE_MIRROR}" ]; then \
        sed -i "s#https://dl-cdn.alpinelinux.org/alpine#${ALPINE_MIRROR}#g" /etc/apk/repositories; \
    fi \
    && apk add --no-cache ca-certificates tzdata wget

WORKDIR /

COPY --from=downloader /pocketbase /usr/local/bin/pocketbase
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
