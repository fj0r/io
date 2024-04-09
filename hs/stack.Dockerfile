ARG GHC_OS=ubuntu20.04
FROM fj0rd/io

ENV STACK_ROOT=/opt/stack GHC_ROOT=/opt/ghc
ENV PATH=${GHC_ROOT}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p ${GHC_ROOT} \
  ; ghc_ver=$(curl --retry 3 -sSL https://www.stackage.org/lts -H 'Accept: application/json' | jq -r '.snapshot.ghc') \
  ; ghc_url="https://downloads.haskell.org/~ghc/${ghc_ver}/ghc-${ghc_ver}-x86_64-${GHC_OS}-linux.tar.xz" \
  ; mkdir ghc_install && curl --retry 3 -sSL ${ghc_url} | tar Jxf - -C ghc_install --strip-components=1 \
  ; cd ghc_install && ./configure --prefix=${GHC_ROOT} && make install \
  ; cd .. && rm -rf ghc_install \
  \
  ; mkdir -p ${STACK_ROOT} && mkdir -p ${HOME}/.cabal \
  ; curl --retry 3 -sSL https://get.haskellstack.org/ | sh \
  #; stack update \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save -f ${STACK_ROOT}/config.yaml" \
  ;

COPY ghci /root/.ghci

RUN set -eux \
  ; mkdir -p ${LS_ROOT}/haskell \
  ; hls_version=$(curl --retry 3 -sSL https://api.github.com/repos/haskell/haskell-language-server/releases/latest | jq -r '.tag_name') \
  ; ghc_version=$(stack ghc -- --numeric-version) \
  ; curl --retry 3 -sSL https://downloads.haskell.org/~hls/haskell-language-server-${hls_version}/haskell-language-server-${hls_version}-x86_64-linux-${GHC_OS}.tar.xz \
        | tar Jxvf - -C ${LS_ROOT}/haskell --strip-components=1 \
          haskell-language-server-${hls_version}/bin/haskell-language-server-${ghc_version} \
          haskell-language-server-${hls_version}/bin/haskell-language-server-wrapper \
          haskell-language-server-${hls_version}/lib/${ghc_version} \
  ; find ${LS_ROOT}/haskell -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ;
