FROM fj0rd/io:base as assets

ARG wasmtime_repo=bytecodealliance/wasmtime
ARG just_repo=casey/just
ARG watchexec_repo=watchexec/watchexec
ARG websocat_repo=vi/websocat

ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /opt/assets \
  \
  ; just_ver=$(xh $github_api/${just_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; just_url=https://github.com/${just_repo}/releases/download/${just_ver}/just-${just_ver}-x86_64-unknown-linux-musl.tar.gz \
  ; xh -F ${just_url} | tar zxf - -C /opt/assets just \
  \
  ; watchexec_ver=$(xh $github_api/${watchexec_repo}/releases $github_header | jq -r '.[0].tag_name' | cut -c 6-) \
  ; watchexec_url=https://github.com/${watchexec_repo}/releases/download/cli-v${watchexec_ver}/watchexec-${watchexec_ver}-x86_64-unknown-linux-musl.tar.xz \
  ; xh -F ${watchexec_url} | tar Jxf - --strip-components=1 -C /opt/assets watchexec-${watchexec_ver}-x86_64-unknown-linux-musl/watchexec \
  \
  ; websocat_ver=$(xh $github_api/${websocat_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; websocat_url=https://github.com/${websocat_repo}/releases/download/${websocat_ver}/websocat_amd64-linux-static \
  ; xh -Fo /opt/assets/websocat ${websocat_url} ; chmod +x /opt/assets/websocat \
  \
  ; wasmtime_ver=$(xh $github_api/${wasmtime_repo}/releases $github_header | jq -r '[.[]|select(.prerelease == false)][0].tag_name') \
  ; wasmtime_url=https://github.com/${wasmtime_repo}/releases/download/${wasmtime_ver}/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz \
  ; xh -F ${wasmtime_url} | tar Jxf - --strip-components=1 -C /opt/assets wasmtime-${wasmtime_ver}-x86_64-linux/wasmtime \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip




FROM fj0rd/io:base

ARG nvim_repo=neovim/neovim
ARG nvim_config=fj0r/nvim-lua

ARG github_header="Accept:application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      pwgen openssh-server \
      zsh git git-flow tcpdump socat \
      python3 python3-pip ipython3 \
      # python3-dev python3-setuptools \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; mkdir -p /var/run/sshd \
  ; sed -i /etc/ssh/sshd_config \
        -e 's!.*\(AuthorizedKeysFile\).*!\1 /etc/authorized_keys/%u!' \
        -e 's!.*\(GatewayPorts\).*!\1 yes!' \
        -e 's!.*\(PasswordAuthentication\).*yes!\1 no!' \
  ; echo "Match Address 10.0.0.0/8,172.17.0.0/16,192.168.0.0/16\n    PasswordAuthentication yes" \
        >> /etc/ssh/sshd_config \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

#######################
#         dev         #
#######################

COPY --from=assets /opt/assets /usr/local/bin

RUN set -eux \
  ; xh -F https://deb.nodesource.com/setup_16.x | bash - \
  ; apt-get install -y --no-install-recommends gnupg nodejs build-essential \
  \
  ; nvim_ver=$(xh $github_api/${nvim_repo}/releases $github_header | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; nvim_url=https://github.com/${nvim_repo}/releases/download/${nvim_ver}/nvim-linux64.tar.gz \
  ; xh -F ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  ; strip /usr/local/bin/nvim \
  ; pip3 --no-cache-dir install \
        neovim neovim-remote debugpy \
        # aiohttp aiofile fastapi uvicorn fabric \
        PyParsing decorator more-itertools \
        typer hydra-core pyyaml invoke \
        requests cachetools chronyk fn.py \
  \
  ; cfg_home=/etc/skel \
  ; git clone --depth=1 https://github.com/fj0r/zsh.git $cfg_home/.zshrc.d \
  ; cp $cfg_home/.zshrc.d/_zshrc $cfg_home/.zshrc \
  \
  ; mkdir -p /opt/language-server \
  ; mkdir -p /opt/vim \
  \
  ; mkdir $cfg_home/.config \
  ; ln -sf $cfg_home/.config $cfg_home/.zshrc* /root \
  \
  ; nvim_home=$cfg_home/.config/nvim \
  \
  ; nvim_config_ver=$(xh $github_api/${nvim_config}/releases $github_header | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; nvim_config_url=https://github.com/${nvim_config}/releases/download/${nvim_config_ver}/nvim-cfg.tar.gz \
  ; xh -F ${nvim_config_url} | tar zxf - -C $cfg_home/.config \
  \
  #; git clone --recursive --shallow-submodules --depth=1 https://github.com/fj0r/nvim-lua.git $nvim_home \
  #; nvim --headless +'autocmd User PackerComplete quitall' +'PackerSync' \
  #; rm -rf $nvim_home/pack/packer/start/*/.git \
  \
  ; npm install -g pyright \
                   vscode-json-languageserver \
                   yaml-language-server \
  ; sed -i "s/\(exports.KUBERNETES_SCHEMA_URL = \)\(.*\)$/\1process.env['KUBERNETES_SCHEMA_URL'] || \2/" $(dirname $(which yaml-language-server))/../lib/node_modules/yaml-language-server/out/server/src/languageservice/utils/schemaUrls.js \
  ; mv $nvim_home/pack /opt/vim \
  ; ln -sf /opt/vim/pack $nvim_home \
  \
  ; coc_lua_bin_repo=josa42/coc-lua-binaries \
  ; lua_ls_ver=$(xh $github_api/${coc_lua_bin_repo}/releases $github_header | jq -r '.[0].tag_name') \
  ; lua_ls_url=https://github.com/${coc_lua_bin_repo}/releases/download/${lua_ls_ver}/lua-language-server-linux.tar.gz \
  ; mkdir -p /opt/language-server/sumneko_lua \
  ; xh -F ${lua_ls_url} | tar zxf - \
      -C /opt/language-server/sumneko_lua \
      --strip-components=1 \
  \
  ; npm cache clean -f \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


WORKDIR /world

ENV SSH_USERS=
ENV SSH_ENABLE_ROOT=
ENV SSH_OVERRIDE_HOST_KEYS=

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
