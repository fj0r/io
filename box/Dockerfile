FROM fj0rd/io:base

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
ARG nvim_repo=neovim/neovim
ARG nvim_config=fj0r/nvim-lua
ARG wasmtime_repo=bytecodealliance/wasmtime
ARG just_repo=casey/just
ARG watchexec_repo=watchexec/watchexec
ARG yq_repo=mikefarah/yq
ARG websocat_repo=vi/websocat
ARG pup_repo=ericchiang/pup
ARG rg_repo=BurntSushi/ripgrep

ARG github_header="Accept: application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos

RUN set -eux \
  ; rg_ver=$(curl -sSL -H "'$github_header'" $github_api/${rg_repo}/releases | jq -r '.[0].tag_name') \
  ; rg_url=https://github.com/${rg_repo}/releases/download/${rg_ver}/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz \
  ; curl -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 ripgrep-${rg_ver}-x86_64-unknown-linux-musl/rg \
  \
  ; just_ver=$(curl -sSL -H "'$github_header'" $github_api/${just_repo}/releases | jq -r '.[0].tag_name') \
  ; just_url=https://github.com/${just_repo}/releases/download/${just_ver}/just-${just_ver}-x86_64-unknown-linux-musl.tar.gz \
  ; curl -sSL ${just_url} | tar zxf - -C /usr/local/bin just \
  \
  ; watchexec_ver=$(curl -sSL -H "'$github_header'" $github_api/${watchexec_repo}/releases | jq -r '.[0].tag_name' | cut -c 6-) \
  ; watchexec_url=https://github.com/${watchexec_repo}/releases/download/cli-v${watchexec_ver}/watchexec-${watchexec_ver}-x86_64-unknown-linux-musl.tar.xz \
  ; curl -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /usr/local/bin watchexec-${watchexec_ver}-x86_64-unknown-linux-musl/watchexec \
  \
  ; yq_ver=$(curl -sSL -H "'$github_header'" $github_api/${yq_repo}/releases | jq -r '.[0].tag_name') \
  ; yq_url=https://github.com/${yq_repo}/releases/download/${yq_ver}/yq_linux_amd64 \
  ; curl -sSLo /usr/local/bin/yq ${yq_url} ; chmod +x /usr/local/bin/yq \
  \
  ; websocat_ver=$(curl -sSL -H "'$github_header'" $github_api/${websocat_repo}/releases | jq -r '.[0].tag_name') \
  ; websocat_url=https://github.com/${websocat_repo}/releases/download/${websocat_ver}/websocat_amd64-linux-static \
  ; curl -sSLo /usr/local/bin/websocat ${websocat_url} ; chmod +x /usr/local/bin/websocat \
  \
  ; pup_ver=$(curl -sSL -H "'$github_header'" $github_api/${pup_repo}/releases | jq -r '.[0].tag_name') \
  ; pup_url=https://github.com/${pup_repo}/releases/download/${pup_ver}/pup_${pup_ver}_linux_amd64.zip \
  ; curl -sSLo pup.zip ${pup_url} && unzip pup.zip && rm -f pup.zip && chmod +x pup && mv pup /usr/local/bin/ \
  \
  ; wasmtime_ver=$(curl -sSL -H "'$github_header'" $github_api/${wasmtime_repo}/releases | jq -r '[.[]|select(.prerelease == false)][0].tag_name') \
  ; wasmtime_url=https://github.com/${wasmtime_repo}/releases/download/${wasmtime_ver}/wasmtime-${wasmtime_ver}-x86_64-linux.tar.xz \
  ; curl -sSL ${wasmtime_url} | tar Jxf - --strip-components=1 -C /usr/local/bin wasmtime-${wasmtime_ver}-x86_64-linux/wasmtime
  #; find /usr/local/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip

RUN set -eux \
  ; curl -sL https://deb.nodesource.com/setup_16.x | bash - \
  ; apt-get install -y --no-install-recommends gnupg nodejs build-essential \
  \
  ; nvim_ver=$(curl -sSL -H "'$github_header'" $github_api/${nvim_repo}/releases | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; nvim_url=https://github.com/${nvim_repo}/releases/download/${nvim_ver}/nvim-linux64.tar.gz \
  ; curl -sSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  #; strip /usr/local/bin/nvim \
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
  ; nvim_config_ver=$(curl -sSL -H "'$github_header'" $github_api/${nvim_config}/releases | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; nvim_config_url=https://github.com/${nvim_config}/releases/download/${nvim_config_ver}/nvim-cfg.tar.gz \
  ; curl -sSL ${nvim_config_url} | tar zxf - -C $cfg_home/.config \
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
  ; lua_ls_ver=$(curl -sSL -H "'$github_header'" $github_api/${coc_lua_bin_repo}/releases | jq -r '.[0].tag_name') \
  ; lua_ls_url=https://github.com/${coc_lua_bin_repo}/releases/download/${lua_ls_ver}/lua-language-server-linux.tar.gz \
  ; mkdir -p /opt/language-server/sumneko_lua \
  ; curl -sSL ${lua_ls_url} | tar zxf - \
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