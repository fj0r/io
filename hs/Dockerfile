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
  ; ghc_ver=$(xh -F https://www.stackage.org/lts Accept:application/json | jq -r '.snapshot.ghc') \
  ; ghc_url=https://downloads.haskell.org/~ghc/${ghc_ver}/ghc-${ghc_ver}-x86_64-deb10-linux.tar.xz \
  ; xh -F ${ghc_url} | tar Jxf - \
  ; cd ghc-${ghc_ver} && ./configure --prefix=${GHC_ROOT} && make install \
  ; cd .. && rm -rf ghc-${ghc_ver} \
  \
  ; mkdir -p ${STACK_ROOT} && mkdir -p ${HOME}/.cabal \
  ; xh -F https://get.haskellstack.org/ | sh \
  ; stack update \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  # JuicyPixels xhtml criterion weigh alex happy
  # cassava diagrams \
  ; stack install -j1 --no-interleaved-output \
      ghcid haskell-dap ghci-dap haskell-debug-adapter \
      optparse-applicative shelly process unix \
      time clock hpc pretty filepath directory zlib \
      array hashtables dlist binary bytestring text \
      containers hashable unordered-containers vector \
      deepseq call-stack primitive ghc-prim \
      template-haskell aeson yaml taggy mustache \
      flow lens recursion-schemes fixed mtl fgl \
      parsers megaparsec Earley boomerang \
      free extensible-effects extensible-exceptions freer \
      bound unbound-generics transformers transformers-compat \
      syb uniplate singletons dimensional \
      monad-par parallel async stm classy-prelude \
      persistent memory cryptonite \
      mwc-random MonadRandom random \
      katip monad-logger monad-journal \
      regex-base regex-posix regex-compat \
      pipes conduit machines \
      http-conduit wreq HTTP html websockets multipart \
      servant scotty wai network network-uri warp \
      QuickCheck smallcheck hspec \
      hmatrix linear statistics ad integration arithmoi \
  ; rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; stack install flow \
  ; stack new hello rio && rm -rf hello \
  ; stack new hello && rm -rf hello \
  ; yq e --inplace ".allow-different-user=true" ${STACK_ROOT}/config.yaml \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project

RUN set -eux \
  ; mkdir -p /opt/language-server/haskell \
  ; hls_version=$(xh https://api.github.com/repos/haskell/haskell-language-server/releases Accept:application/vnd.github.v3+json| jq -r '.[0].tag_name') \
  ; ghc_version=$(stack ghc -- --version | grep -oP 'version \K([0-9\.]+)') \
  ; xh -F https://github.com/haskell/haskell-language-server/releases/download/${hls_version}/haskell-language-server-wrapper-Linux.gz | gzip -d > /opt/language-server/haskell/haskell-language-server-wrapper \
  ; xh -F https://github.com/haskell/haskell-language-server/releases/download/${hls_version}/haskell-language-server-Linux-${ghc_version}.gz | gzip -d > /opt/language-server/haskell/haskell-language-server-${ghc_version} \
  ; chmod +x /opt/language-server/haskell/* \
  ; find /opt/language-server/haskell -type f -links 1 -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; for l in /opt/language-server/haskell/*; do ln -fs $l /usr/local/bin; done

COPY ghci /root/.ghci
COPY config.ustc.yaml ${STACK_ROOT}/config.ustc.yaml
