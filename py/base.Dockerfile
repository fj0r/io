FROM debian:testing-slim
ARG PIP_FLAGS="--break-system-packages"

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      locales tzdata \
      python3 python3-pip \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  ; sed -i /etc/locale.gen \
		-e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
		-e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  ; locale-gen \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        httpx aiofile aiostream fastapi uvicorn \
        debugpy pytest pydantic PyParsing \
        ipython typer pydantic-settings pyyaml \
        boltons decorator \
        pyiceberg[s3fs,pyarrow,pandas] \
  ;

WORKDIR /app
CMD  ["python", "--host", "0.0.0.0", "--port", "3000", "/app/server.py" ]
