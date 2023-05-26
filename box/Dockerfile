ARG BASEIMAGE=fj0rd/io:base
#--break-system-packages
ARG PIP_FLAGS=""

FROM ${BASEIMAGE}  as nu
RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /opt/assets \
  \
  ; nu_ver=$(curl -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/latest/download/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${nu_url} | tar zxf - -C /opt/assets --strip-components=1 \
  ; rm -f /opt/assets/nu_plugin_example /opt/assets/README.txt /opt/assets/LICENSE \
  \
  ; zoxide_ver=$(curl -sSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${zoxide_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${zoxide_url} | tar zxf - -C /opt/assets zoxide \
  \
  ; just_ver=$(curl -sSL https://api.github.com/repos/casey/just/releases/latest | jq -r '.tag_name') \
  ; just_url="https://github.com/casey/just/releases/latest/download/just-${just_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${just_url} | tar zxf - -C /opt/assets just \
  \
  ; watchexec_ver=$(curl -sSL https://api.github.com/repos/watchexec/watchexec/releases/latest  | jq -r '.tag_name' | cut -c 2-) \
  ; watchexec_url="https://github.com/watchexec/watchexec/releases/latest/download/watchexec-${watchexec_ver}-x86_64-unknown-linux-gnu.tar.xz" \
  ; curl -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /opt/assets --wildcards '*/watchexec' \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; dust_ver=$(curl -sSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${dust_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/dust' \
  \
  ; yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz" \
  ; curl -sSL ${yq_url} | tar zxf - ./yq_linux_amd64 && mv yq_linux_amd64 /opt/assets/yq \
  \
  ; pup_ver=$(curl -sSL https://api.github.com/repos/ericchiang/pup/releases/latest | jq -r '.tag_name') \
  ; pup_url="https://github.com/ericchiang/pup/releases/download/${pup_ver}/pup_${pup_ver}_linux_amd64.zip" \
  ; curl -sSL ${pup_url} -o pup.zip && unzip pup.zip && rm -f pup.zip && chmod +x pup && mv pup /opt/assets \
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
      git pwgen python3 python3-pip ipython3 \
      # python3-dev python3-setuptools \
  \
  ; wasmtime_ver=$(curl -sSL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r '.tag_name') \
  ; wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz" \
  ; curl -sSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/wasmtime' \
  \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} \
        # aiofile fastapi uvicorn \
        debugpy pydantic pytest \
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
ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH

RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg2 build-essential xclip \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p ${LS_ROOT} \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
  ; chown -R root:root ${NODE_ROOT}/lib \
  ; npm cache clean -f \
  \
  ; lslua_ver=$(curl -sSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name') \
  ; lslua_url="https://github.com/LuaLS/lua-language-server/releases/latest/download/lua-language-server-${lslua_ver}-linux-x64.tar.gz" \
  ; mkdir -p ${LS_ROOT}/lua \
  ; curl -sSL ${lslua_url} | tar zxf - -C ${LS_ROOT}/lua \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz" \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  ; pip3 install --no-cache-dir ${PIP_FLAGS} neovim \
  ;

