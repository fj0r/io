# base -> gateway vpn mihomo lego
# s3
# common -> sidecar, ci
# box -> java typst flink
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
  #; wasmtime_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r '.tag_name') \
  #; wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz" \
  #; curl --retry 3 -fsSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/wasmtime' \
  \
  #; spin_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/fermyon/spin/releases/latest | jq -r '.tag_name') \
  #; spin_url="https://github.com/fermyon/spin/releases/download/${spin_ver}/spin-${spin_ver}-linux-amd64.tar.gz" \
  #; curl --retry 3 -fsSL ${spin_url} | tar zxf - -C /usr/local/bin spin \
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
        typer pydantic-settings pyyaml \
        boltons decorator \
        #pyiceberg[s3fs,pyarrow,pandas] \
  \
  ; duck_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/duckdb/duckdb/releases/latest | jq -r '.tag_name') \
  ; duck_url="https://github.com/duckdb/duckdb/releases/download/${duck_ver}/duckdb_cli-linux-amd64.gz" \
  ; curl --retry 3 -fsSL ${duck_url} | zcat > /usr/local/bin/duckdb \
  ; chmod +x /usr/local/bin/duckdb \
  ; for x in httpfs delta ducklake iceberg postgres sqlite fts \
  ; do sudo -u master duckdb -c "install ${x};"; done \
  \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
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
  ; node_version=$(curl --retry 3 -fsSL https://nodejs.org/dist/index.json | jq -r '[.[]|select(.lts != false)][0].version') \
  ; curl --retry 3 -fsSL https://nodejs.org/dist/${node_version}/node-${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} ty \
  ; npm install --location=global \
        @typespec/compiler @typespec/json-schema \
        vscode-langservers-extracted \
        yaml-language-server \
  ; chown root:root -R ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  \
  # ; lslua_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name') \
  # ; lslua_url="https://github.com/LuaLS/lua-language-server/releases/download/${lslua_ver}/lua-language-server-${lslua_ver}-linux-x64.tar.gz" \
  # ; mkdir -p ${LS_ROOT}/lua \
  # ; curl --retry 3 -fsSL ${lslua_url} | tar zxf - -C ${LS_ROOT}/lua \
  # ; chown master:master -R ${LS_ROOT}/lua \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

