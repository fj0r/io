ARG BASEIMAGE=ghcr.io/fj0r/io:latest
FROM ${BASEIMAGE}

RUN set -eux \
  ; sudo apt-get update \
  ; sudo apt-get upgrade -y \
  ; sudo npm install --location=global \
        typescript typescript-language-server vite \
        solid-js solid-start vite-plugin-solid \
  ; sudo chown -R root:root ${NODE_ROOT}/lib \
  ; sudo npm cache clean -f \
  #; npx degit solidjs/templates/ts my-solid-project --yes \
  ; sudo apt-get autoremove -y \
  ; sudo apt-get clean -y \
  ; sudo rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; sudo git clone --depth=1 https://github.com/microsoft/vscode-node-debug2.git ${LS_ROOT}/vscode-node-debug2 \
  ; cd ${LS_ROOT}/vscode-node-debug2 \
  ; sudo npm install \
  ; NODE_OPTIONS=--no-experimental-fetch npm run build \
  ; sudo chown -R root:root ${LS_ROOT}/vscode-node-debug2 \
  ; sudo npm cache clean -f

