ARG BASE_IMAGE=fj0rd/io:latest
FROM ${BASE_IMAGE}

ENV PNPM_HOME=/opt/pnpm
ENV PATH=${PNPM_HOME}:$PATH
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
  ; npm install --location=global pnpm \
  ; mkdir -p ${PNPM_HOME} \
  ; pnpm config set store-dir ${PNPM_HOME} \
  ; npm cache clean -f \
  ; npm install --location=global \
        rescript \
        typescript-language-server typescript \
        vite vite-plugin-solid solid-js \
        @volar/vue-language-server vue \
  ; chown -R root:root ${NODE_ROOT}/lib \
  #; npx degit solidjs/templates/ts my-solid-project --yes \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; git clone --depth=1 https://github.com/microsoft/vscode-node-debug2.git ${LS_ROOT}/vscode-node-debug2 \
  ; cd ${LS_ROOT}/vscode-node-debug2 \
  ; npm install \
  ; NODE_OPTIONS=--no-experimental-fetch npm run build \
  ; chown -R root:root ${LS_ROOT}/vscode-node-debug2 \
  ; npm cache clean -f

