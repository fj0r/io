FROM fj0rd/io

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
  ; npm install --location=global \
        typescript-language-server typescript \
        @volar/vue-language-server \
  ; npm cache clean -f \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

