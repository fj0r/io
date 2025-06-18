FROM ghcr.io/fj0r/io:root

RUN set -eux \
  ; apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends graphviz \
      fonts-noto-cjk \
      fonts-noto-cjk-extra \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ; pip3 --default-timeout=100 --no-cache-dir install diagrams

