#FROM fj0rd/io:base as assets
#
#RUN set -eux \
#  ; apt-get update \
#  ; apt-get upgrade -y \
#  ; DEBIAN_FRONTEND=noninteractive \
#    apt-get install -y --no-install-recommends binutils \
#  ; mkdir -p /opt/assets \
#  \
#  ; wasmtime_url=$(xh https://api.github.com/repos/bytecodealliance/wasmtime/releases Accept:application/vnd.github.v3+json \
#                 | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-linux | grep -v api) \
#  ; xh -F ${wasmtime_url} | tar Jxf - --strip-components=1 -C /opt/assets --wildcards '*/wasmtime' \
#  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip



FROM fj0rd/io:base
#COPY --from=assets /opt/assets /usr/local/bin

ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos
ENV PYTHONUNBUFFERED=x

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      pwgen zsh git git-flow \
      python3 python3-pip ipython3 \
      # python3-dev python3-setuptools \
  ; pip3 --no-cache-dir install \
        # aiofile fastapi uvicorn \
        debugpy pydantic pytest fn.py \
        httpx hydra-core typer pyyaml deepmerge \
        PyParsing structlog python-json-logger \
        decorator more-itertools cachetools \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#######################
#         dev         #
#######################
ARG nvim_repo=neovim/neovim
ARG nvim_config=fj0r/nvim-lua

RUN set -eux \
  ; cfg_home=/etc/skel \
  ; mkdir -p $cfg_home/.config \
  ; ln -sf $cfg_home/.config /root \
  ; git clone --depth=1 https://github.com/fj0r/zsh.git $cfg_home/.zshrc.d \
  ; cp $cfg_home/.zshrc.d/_zshrc $cfg_home/.zshrc \
  ; ln -sf $cfg_home/.zshrc* /root \
  \
  ; xh -F https://deb.nodesource.com/setup_16.x | bash - \
  ; apt-get install -y --no-install-recommends gnupg nodejs build-essential \
  \
  ; mkdir -p /opt/language-server \
  ; npm install -g pyright \
                   vscode-json-languageserver \
                   yaml-language-server \
  ; sed -i "s/\(exports.KUBERNETES_SCHEMA_URL = \)\(.*\)$/\1process.env['KUBERNETES_SCHEMA_URL'] || \2/" $(dirname $(which yaml-language-server))/../lib/node_modules/yaml-language-server/out/server/src/languageservice/utils/schemaUrls.js \
  ; npm cache clean -f \
  \
  ; coc_lua_bin_repo=josa42/coc-lua-binaries \
  ; lua_ls_ver=$(xh $github_api/${coc_lua_bin_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; lua_ls_url=https://github.com/${coc_lua_bin_repo}/releases/download/${lua_ls_ver}/lua-language-server-linux.tar.gz \
  ; mkdir -p /opt/language-server/sumneko_lua \
  ; xh -F ${lua_ls_url} | tar zxf - \
      -C /opt/language-server/sumneko_lua \
      --strip-components=1 \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  \
  ; nvim_ver=$(xh $github_api/${nvim_repo}/releases $github_header | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; nvim_url=https://github.com/${nvim_repo}/releases/download/${nvim_ver}/nvim-linux64.tar.gz \
  ; xh -F ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; pip3 --no-cache-dir install \
        neovim neovim-remote \
  ; mkdir -p /opt/vim \
  ; nvim_home=$cfg_home/.config/nvim \
  ; nvim_config_ver=$(xh $github_api/${nvim_config}/releases $github_header | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; nvim_config_url=https://github.com/${nvim_config}/releases/download/${nvim_config_ver}/nvim-cfg.tar.gz \
  ; xh -F ${nvim_config_url} | tar zxf - -C $cfg_home/.config \
  ; mv $nvim_home/pack /opt/vim \
  ; ln -sf /opt/vim/pack $nvim_home


