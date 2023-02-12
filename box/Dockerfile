#FROM fj0rd/scratch:goofys as goofys
FROM fj0rd/io:base as nu
RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /opt/assets \
  \
  ; nu_ver=$(curl -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/latest/download/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${nu_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/nu' \
  \
  ; zoxide_ver=$(curl -sSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${zoxide_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${zoxide_url} | tar zxf - -C /opt/assets zoxide \
  \
  ; just_ver=$(curl -sSL https://api.github.com/repos/casey/just/releases/latest | jq -r '.tag_name') \
  ; just_url="https://github.com/casey/just/releases/latest/download/just-${just_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${just_url} | tar zxf - -C /opt/assets just \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; dust_ver=$(curl -sSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${dust_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/dust' \
  \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s


FROM fj0rd/io:base
COPY --from=nu /opt/assets /usr/local/bin
#COPY --from=goofys / /

ENV NVIM_PRESET=core \
    PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      git pwgen s3fs python3 python3-pip ipython3 \
      # python3-dev python3-setuptools \
  \
  ; wasmtime_ver=$(curl -sSL https://api.github.com/repos/bytecodealliance/wasmtime/releases/latest | jq -r '.tag_name') \
  ; wasmtime_url="https://github.com/bytecodealliance/wasmtime/releases/latest/download/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz" \
  ; curl -sSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin --wildcards '*/wasmtime' \
  \
  ; pip3 --no-cache-dir install \
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
ENV NODE_ROOT=/opt/node
ENV PATH=${NODE_ROOT}/bin:$PATH

# '[.[]|select(.prerelease == false)][0].assets[].browser_download_url'
# '.[0].assets[].browser_download_url'
RUN set -eux \
  ; apt update \
  ; apt-get install -y --no-install-recommends gnupg build-essential xclip \
  ; mkdir -p ${NODE_ROOT} \
  ; node_version=$(curl -sSL https://nodejs.org/en/download/ | rg 'Latest LTS Version.*<strong>(.+)</strong>' -or '$1') \
  ; curl -sSL https://nodejs.org/dist/v${node_version}/node-v${node_version}-linux-x64.tar.xz \
    | tar Jxf - --strip-components=1 -C ${NODE_ROOT} \
  \
  ; mkdir -p /opt/language-server \
  ; npm install -g npm@8 \
  ; npm install --location=global \
        quicktype \
        pyright \
        vscode-langservers-extracted \
        yaml-language-server \
        neovim \
  ; npm cache clean -f \
  \
  ; lslua_ver=$(curl -sSL https://api.github.com/repos/LuaLS/lua-language-server/releases/latest | jq -r '.tag_name') \
  ; lslua_url="https://github.com/LuaLS/lua-language-server/releases/latest/download/lua-language-server-${lslua_ver}-linux-x64.tar.gz" \
  ; mkdir -p /opt/language-server/lua-language-server \
  ; curl -sSL ${lslua_url} | tar zxf - -C /opt/language-server/lua-language-server \
  ; ln -fs /opt/language-server/lua-language-server/bin/lua-language-server /usr/local/bin \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; nvim_url=https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; git clone --depth=1 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  ; nvim --headless "+Lazy! sync" +qa \
  \
  #; tsl=$(cat $XDG_CONFIG_HOME/nvim/lua/settings/treesitter.json|jq -r '.languages|join(" ")') \
  #; nvim --headless -c "TSUpdateSync ${tsl}" -c 'quit' \
  ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  ; pip3 --no-cache-dir install neovim \
  ;

ENV S3ENDPOINT=
ENV S3BUCKET=
ENV S3MOUNTPOINT=
ENV S3REGION=
ENV S3ACCESS_KEY=
ENV S3SECRET_KEY=
