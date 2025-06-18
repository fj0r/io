FROM ghcr.io/fj0r/io

RUN set -eux \
  ; sudo apt-get update -y \
  ; DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install -y --no-install-recommends graphviz \
      fonts-noto-cjk \
      fonts-noto-cjk-extra \
  ; sudo apt-get autoremove -y \
  ; sudo apt-get clean -y \
  ; sudo rm -rf /var/lib/apt/lists/* \
  ; sudo pip3 --default-timeout=100 --no-cache-dir install diagrams

