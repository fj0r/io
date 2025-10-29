ARG BASEIMAGE=ghcr.io/fj0r/io:root
FROM ${BASEIMAGE}

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; npm install --location=global \
        typescript typescript-language-server vite \
        solid-js solid-start vite-plugin-solid \
  ; chown root:root -R ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  #; npx degit solidjs/templates/ts my-solid-project --yes \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;
