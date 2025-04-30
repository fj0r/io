# base -> gateway vpn mihomo lego
# s3
# common -> sidecar, ci
# box -> php java pg16 typst flink
ARG BASEIMAGE=ghcr.io/fj0r/io:nu
FROM ${BASEIMAGE}

ARG PIP_FLAGS="--break-system-packages"
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      pwgen python3 python3-pip \
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
        debugpy pytest pydantic pydantic-graph PyParsing \
        ipython typer pydantic-settings pyyaml \
        boltons decorator \
        #pyiceberg[s3fs,pyarrow,pandas] \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

#######################
#         dev         #
#######################
ENV LS_ROOT=/opt/language-server
ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH
ENV BUILD_DEPS="\
    cmake \
    "

RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg2 build-essential ${BUILD_DEPS:-} \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl --retry 3 -sSL https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts != false)][0].version') \
  ; curl --retry 3 -sSL https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        @typespec/compiler @typespec/json-schema \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; chown -R root:root ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  \
  ; lslua_ver=$(curl --retry 3 -sSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name') \
  ; lslua_url="https://github.com/LuaLS/lua-language-server/releases/latest/download/lua-language-server-${lslua_ver}-linux-x64.tar.gz" \
  ; mkdir -p ${LS_ROOT}/lua \
  ; curl --retry 3 -sSL ${lslua_url} | tar zxf - -C ${LS_ROOT}/lua \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

