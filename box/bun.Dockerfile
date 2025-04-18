ARG BASEIMAGE=ghcr.io/fj0r/io:common
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      git openssh-client pwgen python3 python3-pip \
      # python3-dev python3-setuptools \
  \
  ; ln -sf /usr/bin/python3 /usr/bin/python \
  ; wasmtime_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r '.tag_name') \
  ; wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz" \
  ; curl --retry 3 -sSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/wasmtime' \
  \
  #; spin_ver=$(curl --retry 3 -sSL https://api.github.com/repos/fermyon/spin/releases/latest | jq -r '.tag_name') \
  #; spin_url="https://github.com/fermyon/spin/releases/download/${spin_ver}/spin-${spin_ver}-linux-amd64.tar.gz" \
  #; curl --retry 3 -sSL ${spin_url} | tar zxf - -C /usr/local/bin spin \
  \
  #; pydeb="" \
  #; for pkg in \
  #      debugpy pydantic pytest \
  #      httpx typer yaml \
  #      pyparsing structlog \
  #      decorator more-itertools cachetools \
  #; do pydeb+="python3-${pkg} "; done \
  #; apt-get install -y --no-install-recommends $pydeb \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        httpx aiofile aiostream fastapi uvicorn \
        debugpy pytest pydantic PyParsing \
        ipython typer pydantic-settings pyyaml \
        boltons decorator \
        #pyiceberg[s3fs,pyarrow,pandas] \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; nu_ver=$(curl --retry 3 -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/download/${nu_ver}/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${nu_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/nu' '*/nu_plugin_query' \
  \
  ; for x in nu nu_plugin_query \
  ; do strip -s /usr/local/bin/$x; done \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; git clone --depth=3 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nushell; git log -1 --date=iso; cd $opwd \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#######################
#         dev         #
#######################
ENV LS_ROOT=/opt/language-server
ENV BUN_ROOT=/opt/bun
ENV PATH=${BUN_ROOT}/bin:$PATH

COPY bunfig.toml /root/.bunfig.toml

RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg2 build-essential \
  #; mkdir -p ${BUN_ROOT}/{bin,install/{global,cache}} \
  ; mkdir -p ${BUN_ROOT}/bin ${BUN_ROOT}/install/global ${BUN_ROOT}/install/cache \
  ; mkdir /tmp/bun \
  ; opwd=$PWD \
  ; curl --retry 3 -sSL https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64.zip -o /tmp/bun/bun-linux-x64.zip \
  ; cd /tmp/bun \
  ; unzip bun-linux-x64.zip \
  ; mv bun-linux-x64/bun ${BUN_ROOT}/bin \
  ; cd ${BUN_ROOT}/bin \
  ; ln -fsr bun node \
  ; cd $opwd \
  ; rm -rf /tmp/bun \
  \
  ; mkdir -p ${LS_ROOT} \
  ; bun install --config=/root/.bunfig.toml --global --no-cache \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  \
  ; lslua_ver=$(curl --retry 3 -sSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name') \
  ; lslua_url="https://github.com/LuaLS/lua-language-server/releases/latest/download/lua-language-server-${lslua_ver}-linux-x64.tar.gz" \
  ; mkdir -p ${LS_ROOT}/lua \
  ; curl --retry 3 -sSL ${lslua_url} | tar zxf - -C ${LS_ROOT}/lua \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" \
  ; curl --retry 3 -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip -s /usr/local/bin/nvim \
  ; git clone --depth=3 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  ;

