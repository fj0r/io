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

RUN set -eux \
  ; git clone --depth=1 https://github.com/microsoft/vscode-node-debug2.git /opt/language-server/vscode-node-debug2 \
  ; cd /opt/language-server/vscode-node-debug2 \
  ; npm install \
  ; NODE_OPTIONS=--no-experimental-fetch npm run build

