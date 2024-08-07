ARG BASEIMAGE=ghcr.io/fj0r/io:rs
FROM ${BASEIMAGE}

ARG STACK_FLAGS="--local-bin-path=/usr/local/bin --no-interleaved-output"
ARG STACK_INFO_URL="https://www.stackage.org/lts"
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1

ENV GHCUP_INSTALL_BASE_PREFIX=/opt GHCUP_ROOT=/opt/.ghcup
ENV STACK_ROOT=/opt/stack
ENV PATH=${GHCUP_ROOT}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p ${GHCUP_ROOT}/bin \
  ; mkdir -p ${STACK_ROOT} \
  ; curl --retry 3 -sSLo ${GHCUP_ROOT}/bin/ghcup https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup \
  ; chmod +x ${GHCUP_ROOT}/bin/ghcup \
  ; ghcup install stack \
  ; ghcup install cabal \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  \
  ; ghc_ver=$(curl --retry 3 -sSL ${STACK_INFO_URL} -H 'Accept: application/json' | jq -r '.snapshot.ghc') \
  ; ghcup -s '["GHCupURL", "StackSetupURL"]' install ghc $ghc_ver \
  \
  ; for i in \
      tmp cache trash logs \
  ; do \
      du -hd 1 "${GHCUP_ROOT}/${i}" ;\
      rm -rf "${GHCUP_ROOT}/${i}/*" ;\
    done \
  \
  ; rm -rf ${GHCUP_ROOT}/ghc/${ghc_ver}/share \
  ; nu -c "open ${STACK_ROOT}/config.yaml | merge {allow-different-user: true, allow-newer: true, recommend-stack-upgrade: false} | collect { \$in | save -f ${STACK_ROOT}/config.yaml }" \
  \
  #; ghcup install hls \
  #; hls_ver=$(haskell-language-server-wrapper --numeric-version) \
  #; for i in \
  #  $(ls ${GHCUP_ROOT}/hls/${hls_ver}/lib/haskell-language-server-${hls_ver}/lib/) \
  #; do \
  #    if [ "$i" != "$ghc_ver" ]; then \
  #      rm -rf ${GHCUP_ROOT}/hls/${hls_ver}/lib/haskell-language-server-${hls_ver}/lib/$i; \
  #    fi ;\
  #  done \
  ;

RUN set -eux \
  ; mkdir -p ${LS_ROOT}/haskell \
  ; hls_version=$(curl --retry 3 -sSL https://api.github.com/repos/haskell/haskell-language-server/releases/latest | jq -r '.tag_name') \
  ; ghc_version=$(stack ghc -- --numeric-version) \
  ; curl --retry 3 -sSL https://downloads.haskell.org/~hls/haskell-language-server-${hls_version}/haskell-language-server-${hls_version}-x86_64-linux-unknown.tar.xz \
  | tar Jxvf - -C ${LS_ROOT}/haskell --strip-components=1 \
      haskell-language-server-${hls_version}/bin/haskell-language-server-${ghc_version} \
      haskell-language-server-${hls_version}/bin/haskell-language-server-wrapper \
      haskell-language-server-${hls_version}/lib/${ghc_version} \
  ; find ${LS_ROOT}/haskell -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ;

RUN set -eux \
  ; stack install ${STACK_FLAGS} \
      ghcid implicit-hie haskell-dap ghci-dap haskell-debug-adapter \
      optparse-applicative shelly process unix \
      time clock hpc pretty filepath directory zlib \
      array hashtables dlist binary bytestring text \
      containers hashable vector unordered-containers \
      deepseq call-stack primitive ghc-prim \
      template-haskell aeson yaml taggy \
      lens recursion-schemes fixed mtl fgl \
      parsers megaparsec Earley boomerang \
      free extensible-effects extensible-exceptions \
      bound unbound-generics transformers transformers-compat \
      syb uniplate singletons dimensional \
      monad-par parallel async stm classy-prelude \
      persistent memory cryptonite \
      mwc-random MonadRandom random \
      katip monad-logger \
      regex-base regex-posix regex-compat \
      pipes conduit machines \
      http-conduit wreq HTTP html websockets multipart \
      servant scotty wai network network-uri warp \
      QuickCheck smallcheck hspec \
      hmatrix linear statistics ad integration \
  ; rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; opwd=$PWD \
  ; cd /world && stack new ${STACK_FLAGS} hello-rio rio && cd hello-rio && gen-hie > hie.yaml \
  ; cd /world && stack new ${STACK_FLAGS} hello-haskell && cd hello-haskell && gen-hie > hie.yaml \
  ; cd $opwd \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project

COPY _ghci /root/.ghci
