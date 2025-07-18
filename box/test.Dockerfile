ARG BASEIMAGE=debian:bookworm-slim
FROM ${BASEIMAGE}

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      curl ca-certificates jq binutils \
  \
  ; rg_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  #; sed -i /etc/locale.gen \
  #      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
  #      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  #; locale-gen \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  #; echo "Defaults env_keep += \"PATH\"" >> /etc/sudoers \
  \
  ; nu_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/download/${nu_ver}/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${nu_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/nu' '*/nu_plugin_query' \
  \
  ; for x in nu nu_plugin_query \
  ; do strip -s /usr/local/bin/$x; done \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; MASTER=master \
  ; useradd -mU -G sudo,root -s /usr/local/bin/nu $MASTER \
  \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH
ENV BUILD_DEPS="\
    cmake \
    "
RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg2 build-essential ${BUILD_DEPS:-} \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl --retry 3 -fsSL https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts != false)][0].version') \
  ; curl --retry 3 -fsSL https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; npm install --location=global \
        @typespec/compiler @typespec/json-schema \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; chown root:root -R ${NODE_ROOT}/lib \
  ; npm cache clean -f \
