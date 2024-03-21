ARG BASEIMAGE=fj0rd/io:base
ARG PIP_FLAGS="--break-system-packages"

FROM ${BASEIMAGE} as nu
RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /opt/assets \
  \
  ; nu_ver=$(curl --retry 3 -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/download/${nu_ver}/nu-${nu_ver}-x86_64-linux-musl-full.tar.gz" \
  ; curl --retry 3 -sSL ${nu_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/nu' '*/nu_plugin_query' \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s


FROM ${BASEIMAGE}
ARG PIP_FLAGS
COPY --from=nu /opt/assets /usr/local/bin

ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      git pwgen python3 python3-pip \
      # python3-dev python3-setuptools \
  \
  ; wasmtime_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r '.tag_name') \
  ; wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz" \
  ; curl --retry 3 -sSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/wasmtime' \
  \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        # aiofile fastapi uvicorn \
        ipython debugpy pydantic pytest \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; git clone --depth=3 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nushell; git log -1 --date=iso; cd $opwd \
  ; nu -c 'register /usr/local/bin/nu_plugin_query' \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#######################
#         dev         #
#######################
ENV LS_ROOT=/opt/language-server
ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH

RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg2 build-essential \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl --retry 3 -sSL https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts != false)][0].version') \
  ; curl --retry 3 -sSL https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        quicktype \
  ; chown -R root:root ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

#######################
#     code-server     #
#######################
RUN set -eux \
  ; mkdir -p /opt/code-server/extensions \
  ; mkdir -p /opt/code-server/user-data \
  ; code_ver=$(curl --retry 3 -sSL https://api.github.com/repos/coder/code-server/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; code_url="https://github.com/coder/code-server/releases/download/v${code_ver}/code-server-${code_ver}-linux-amd64.tar.gz" \
  ; curl --retry 3 -sSL ${code_url} | tar zxf - --strip-components=1 -C /opt/code-server \
  \
  ; for i in \
        # asvetliakov.vscode-neovim \
        # vscodevim.vim \
        ms-python.python \
        ms-toolsai.jupyter \
        LouisWT.regexp-preview \
        redhat.vscode-yaml \
        rust-lang.rust \
        bungcip.better-toml \
        serayuzgur.crates \
        Swellaby.vscode-rust-test-adapter \
        haskell.haskell \
        golang.Go \
        julialang.language-julia \
        Vue.volar \
        devsense.phptools-vscode \
  ; do \
        /opt/code-server/bin/code-server \
            --extensions-dir /opt/code-server/extensions \
            --user-data-dir /opt/code-server/user-data \
            --install-extension $i \
  ; done \
  ; rm -rf /opt/code-server/user-data \
  ; mkdir -p /opt/code-server/user-data/Machine \
  ; mkdir -p /opt/code-server/user-data/User \
  ;

COPY code.sh /entrypoint
COPY settings.json /opt/code-server/user-data/Machine
