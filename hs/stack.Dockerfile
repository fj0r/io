FROM fj0rd/io

ENV STACK_ROOT=/opt/stack GHC_ROOT=/opt/ghc
ENV PATH=${GHC_ROOT}/bin:$PATH
ENV GHC_OS=deb10

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p ${GHC_ROOT} \
  ; ghc_ver=$(curl -sSL https://www.stackage.org/lts -H 'Accept: application/json' | jq -r '.snapshot.ghc') \
  ; ghc_url=https://downloads.haskell.org/~ghc/${ghc_ver}/ghc-${ghc_ver}-x86_64-${GHC_OS}-linux.tar.xz \
  ; curl -sSL ${ghc_url} | tar Jxf - \
  ; cd ghc-${ghc_ver} && ./configure --prefix=${GHC_ROOT} && make install \
  ; cd .. && rm -rf ghc-${ghc_ver} \
  \
  ; mkdir -p ${STACK_ROOT} && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  #; stack update \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save -f ${STACK_ROOT}/config.yaml" \
  ;

COPY ghci /root/.ghci

RUN set -eux \
  ; mkdir -p /opt/language-server/haskell \
  ; hls_version=$(curl -sSL https://api.github.com/repos/haskell/haskell-language-server/releases/latest | jq -r '.tag_name') \
  #; hls_version=$(curl https://downloads.haskell.org/~hls/ | rg '>haskell-language-server-(.+)/<' -or '$1' | tail -n 1) \
  ; ghc_version=$(stack ghc -- --numeric-version) \
  ; curl -sSL https://downloads.haskell.org/~hls/haskell-language-server-${hls_version}/haskell-language-server-${hls_version}-x86_64-linux-${GHC_OS}.tar.xz \
        | tar Jxvf - -C /opt/language-server/haskell --strip-components=1 \
          haskell-language-server-${hls_version}/bin/haskell-language-server-${ghc_version} \
          haskell-language-server-${hls_version}/bin/haskell-language-server-wrapper \
          haskell-language-server-${hls_version}/lib/${ghc_version} \
  ; find /opt/language-server/haskell -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; find /opt/language-server/haskell/bin -maxdepth 1 -type f | xargs -i ln -fs {} /usr/local/bin
