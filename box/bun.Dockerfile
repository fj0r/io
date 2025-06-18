ARG BASEIMAGE=ghcr.io/fj0r/io:nu
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; sudo apt-get update \
  ; sudo apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install -y --no-install-recommends \
      pwgen python3 python3-pip \
      # python3-dev python3-setuptools \
  \
  ; sudo ln -sf /usr/bin/python3 /usr/bin/python \
  ; wasmtime_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r '.tag_name') \
  ; wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz" \
  ; curl --retry 3 -sSL ${wasmtime_url} | sudo tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/wasmtime' \
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
  ; sudo pip3 install --no-cache-dir ${PIP_FLAGS} \
        httpx aiofile aiostream fastapi uvicorn \
        debugpy pytest pydantic pydantic-graph PyParsing \
        ipython typer pydantic-settings pyyaml \
        boltons decorator \
        #pyiceberg[s3fs,pyarrow,pandas] \
  \
  ; sudo apt-get autoremove -y \
  ; sudo apt-get clean -y \
  ; sudo rm -rf /var/lib/apt/lists/* \
  ;

#######################
#         dev         #
#######################
ENV LS_ROOT=/opt/language-server
ENV BUN_ROOT=/opt/bun
ENV PATH=${BUN_ROOT}/bin:$PATH
ENV BUILD_DEPS="\
    cmake \
    "

COPY bunfig.toml /root/.bunfig.toml

RUN set -eux \
  ; sudo apt update \
  ; sudo apt-get install -y --no-install-recommends gnupg2 build-essential \
  ; sudo mkdir -p ${BUN_ROOT}/bin ${BUN_ROOT}/install/global ${BUN_ROOT}/install/cache \
  ; sudo mkdir /tmp/bun \
  ; opwd=$PWD \
  ; sudo curl --retry 3 -sSL https://github.com/oven-sh/bun/releases/latest/download/bun-linux-x64.zip -o /tmp/bun/bun-linux-x64.zip \
  ; cd /tmp/bun \
  ; sudo unzip bun-linux-x64.zip \
  ; sudo mv bun-linux-x64/bun ${BUN_ROOT}/bin \
  ; cd ${BUN_ROOT}/bin \
  ; sudo ln -fsr bun node \
  ; cd $opwd \
  ; sudo rm -rf /tmp/bun \
  \
  ; sudo mkdir -p ${LS_ROOT} \
  ; sudo bun install --config=/root/.bunfig.toml --global --no-cache \
        @typespec/compiler @typespec/json-schema \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  \
  ; lslua_ver=$(curl --retry 3 -sSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name') \
  ; lslua_url="https://github.com/LuaLS/lua-language-server/releases/latest/download/lua-language-server-${lslua_ver}-linux-x64.tar.gz" \
  ; sudo mkdir -p ${LS_ROOT}/lua \
  ; curl --retry 3 -sSL ${lslua_url} | sudo tar zxf - -C ${LS_ROOT}/lua \
  \
  ; sudo apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  ; sudo apt-get clean -y \
  ; sudo rm -rf /var/lib/apt/lists/* \
  ;

