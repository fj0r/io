ARG BASE_IMAGE=python:alpine
FROM ${BASE_IMAGE}

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TIMEZONE=Asia/Shanghai

RUN set -eux \
  ; apk update && apk upgrade \
  ; apk add --no-cache tzdata \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  \
  ; apk add --no-cache --virtual .build-deps \
      build-base make coreutils \
  \
  ; pip3 --no-cache-dir install \
        debugpy fastapi uvicorn aiofile pytest \
        httpx typer hydra-core pyyaml deepmerge structlog \
        pydantic PyParsing decorator more-itertools fn.py cachetools \
  \
  ; apk del .build-deps \
  ; rm -rf /var/cache/apk/*
