ARG BASEIMAGE=ghcr.io/fj0r/io:base
FROM ${BASEIMAGE}

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
        s3fs fuse \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
