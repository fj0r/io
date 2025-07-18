ARG BASEIMAGE=ghcr.io/fj0r/io:root
FROM ${BASEIMAGE}

#######################
#     code-server     #
#######################
RUN set -eux \
  ; mkdir -p /opt/code-server/extensions \
  ; mkdir -p /opt/code-server/user-data \
  ; code_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/coder/code-server/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; code_url="https://github.com/coder/code-server/releases/download/v${code_ver}/code-server-${code_ver}-linux-amd64.tar.gz" \
  ; curl --retry 3 -fsSL ${code_url} \
  | tar zxf - --strip-components=1 -C /opt/code-server \
  \
  ; for i in \
        # asvetliakov.vscode-neovim \
        # vscodevim.vim \
        ms-python.python \
        ms-toolsai.jupyter \
        redhat.vscode-yaml \
        rust-lang.rust \
        bungcip.better-toml \
        serayuzgur.crates \
        Swellaby.vscode-rust-test-adapter \
        haskell.haskell \
        golang.Go \
        Vue.volar \
        devsense.phptools-vscode \
  ; do \
        /opt/code-server/bin/code-server \
            --extensions-dir /opt/code-server/extensions \
            --user-data-dir /opt/code-server/user-data \
            --install-extension $i \
  ; done \
  ; rm -rf /opt/code-server/user-data \
  ; mkdir -p /opt/code-server/user-data/Machine \
  ; mkdir -p /opt/code-server/user-data/User \
  ;

COPY code.sh /entrypoint
COPY settings.json /opt/code-server/user-data/Machine
