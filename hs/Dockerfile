FROM fj0rd/io:x

ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV STACK_ROOT=/opt/stack GHCUP_ROOT=/opt/.ghcup
ENV PATH=${GHCUP_ROOT}/bin:$PATH \
    GHCUP_INSTALL_BASE_PREFIX=/opt

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p ${GHCUP_ROOT}/bin \
  ; mkdir -p ${STACK_ROOT} \
  #; curl -sSL https://get-ghcup.haskell.org | sh \
  ; curl -sSLo ${GHCUP_ROOT}/bin/ghcup https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup \
  ; chmod +x ${GHCUP_ROOT}/bin/ghcup \
  ; ghcup install ghc \
  ; ghcup install stack \
  ; ghcup install cabal \
  ; ghcup install hls \
  ; rm -rf ${GHCUP_ROOT}/cache \
  #; rm -rf ${GHCUP_ROOT}/share/doc \
  \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save -f ${STACK_ROOT}/config.yaml" \
  ;

RUN set -eux \
  ; stack install --no-interleaved-output \
      ghcid haskell-dap ghci-dap haskell-debug-adapter \
      optparse-applicative shelly process unix \
      time clock hpc pretty filepath directory zlib \
      array hashtables dlist binary text \
      containers hashable vector unordered-containers \
      deepseq call-stack primitive ghc-prim \
      template-haskell aeson yaml taggy stache \
      lens recursion-schemes fixed mtl fgl \
      parsers megaparsec Earley boomerang \
      free extensible-effects extensible-exceptions freer \
      bound unbound-generics transformers transformers-compat \
      syb uniplate singletons dimensional \
      monad-par parallel async stm classy-prelude \
      persistent memory cryptonite \
      mwc-random MonadRandom random \
      katip monad-logger monad-journal \
      regex-base regex-posix regex-compat \
      flow pipes conduit machines \
      http-conduit wreq HTTP html websockets multipart \
      servant scotty wai network network-uri warp \
      QuickCheck smallcheck hspec \
      hmatrix linear statistics ad integration arithmoi \
  ; rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; opwd=$PWD; cd /world \
  ; stack new hello-rio rio \
  ; stack new hello-haskell \
  ; cd $opwd \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project

COPY ghci /root/.ghci

#RUN set -eux \
#  ; mkdir -p /opt/language-server/haskell \
#  ; hls_version=$(curl -sSL https://api.github.com/repos/haskell/haskell-language-server/releases/latest | jq -r '.tag_name') \
#  #; hls_version=$(curl https://downloads.haskell.org/~hls/ | rg '>haskell-language-server-(.+)/<' -or '$1' | tail -n 1) \
#  ; ghc_version=$(stack ghc -- --numeric-version) \
#  ; curl -sSL https://downloads.haskell.org/~hls/haskell-language-server-${hls_version}/haskell-language-server-${hls_version}-x86_64-linux-deb10.tar.xz \
#        | tar Jxvf - -C /opt/language-server/haskell --strip-components=1 \
#          haskell-language-server-${hls_version}/bin/haskell-language-server-${ghc_version} \
#          haskell-language-server-${hls_version}/bin/haskell-language-server-wrapper \
#          haskell-language-server-${hls_version}/lib/${ghc_version} \
#  ; find /opt/language-server/haskell -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
#  ; find /opt/language-server/haskell/bin -maxdepth 1 -type f | xargs -i ln -fs {} /usr/local/bin

