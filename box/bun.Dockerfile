ARG BASEIMAGE=fj0rd/io:base
#--break-system-packages
ARG PIP_FLAGS=""

FROM ${BASEIMAGE} as nu
RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /opt/assets \
  \
  ; nu_ver=$(curl --retry 3 -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/latest/download/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${nu_url} | tar zxf - -C /opt/assets --strip-components=1 \
  ; rm -f /opt/assets/nu_plugin_example /opt/assets/README.txt /opt/assets/LICENSE \
  \
  ; zoxide_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${zoxide_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${zoxide_url} | tar zxf - -C /opt/assets zoxide \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; pup_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ericchiang/pup/releases/latest | jq -r '.tag_name') \
  ; pup_url="https://github.com/ericchiang/pup/releases/download/${pup_ver}/pup_${pup_ver}_linux_amd64.zip" \
  ; curl --retry 3 -sSL ${pup_url} -o pup.zip && unzip pup.zip && rm -f pup.zip && chmod +x pup && mv pup /opt/assets \
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
  ; git clone --depth=1 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
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
  ; apt-get install -y --no-install-recommends gnupg2 build-essential xclip \
  ; mkdir -p ${BUN_ROOT}/bin \
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
  ; bun install --global --no-cache \
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
  ; strip /usr/local/bin/nvim \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  ;

