ARG BASEIMAGE=ghcr.io/fj0r/io:rs
FROM ${BASEIMAGE}

ARG STACK_FLAGS="--local-bin-path=/usr/local/bin --no-interleaved-output"
ARG STACK_INFO_URL="https://www.stackage.org/lts"
ARG MESSAGE=''
ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1

ENV GHCUP_INSTALL_BASE_PREFIX=/opt GHCUP_ROOT=/opt/.ghcup
ENV STACK_ROOT=/opt/stack
ENV PATH=${GHCUP_ROOT}/bin:$PATH

RUN set -eux \
  ; sudo apt-get update \
  ; sudo apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; sudo apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; sudo mkdir -p ${GHCUP_ROOT}/bin \
  ;  sudomkdir -p ${STACK_ROOT} \
  ; curl --retry 3 -sSLo ${GHCUP_ROOT}/bin/ghcup https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup \
  ; sudo chmod +x ${GHCUP_ROOT}/bin/ghcup \
  ; sudo ghcup install stack \
  ; sudo ghcup install cabal \
  ; sudo stack config set system-ghc --global true \
  ; sudo stack config set install-ghc --global false \
  \
  ; ghc_ver=$(curl -sSL ${STACK_INFO_URL} | rg '<h1>LTS Haskell.+\(.*?([0-9\.]+)\)' -or '$1') \
  ; sudo ghcup -s '["GHCupURL", "StackSetupURL"]' install ghc $ghc_ver \
  \
  ; for i in \
      tmp cache trash logs \
  ; do \
      sudo du -hd 1 "${GHCUP_ROOT}/${i}" ;\
      sudo rm -rf "${GHCUP_ROOT}/${i}/*" ;\
    done \
  \
  ; sudo rm -rf ${GHCUP_ROOT}/ghc/${ghc_ver}/share \
  ; sudo nu -c "open ${STACK_ROOT}/config.yaml | merge {allow-different-user: true, allow-newer: true, recommend-stack-upgrade: false} | collect { \$in | save -f ${STACK_ROOT}/config.yaml }" \
  \
  #; ghcup install hls \
  #; hls_ver=$(haskell-language-server-wrapper --numeric-version) \
  #; for i in \
  #  $(ls ${GHCUP_ROOT}/hls/${hls_ver}/lib/haskell-language-server-${hls_ver}/lib/) \
  #; do \
  #    if [[ "$i" != "$ghc_ver" ]]; then \
  #      rm -rf ${GHCUP_ROOT}/hls/${hls_ver}/lib/haskell-language-server-${hls_ver}/lib/$i; \
  #    fi ;\
  #  done \
  ;

RUN set -eux \
   sudo; mkdir -p ${LS_ROOT}/haskell/tmp \
  ; hls_version=$(curl --retry 3 -sSL https://api.github.com/repos/haskell/haskell-language-server/releases/latest | jq -r '.tag_name') \
  ; ghc_version=$(sudo stack ghc -- --numeric-version) \
  ; curl --retry 3 -sSL https://downloads.haskell.org/~hls/haskell-language-server-${hls_version}/haskell-language-server-${hls_version}-x86_64-linux-unknown.tar.xz \
  | sudo tar Jxvf - -C ${LS_ROOT}/haskell/tmp --strip-components=1 \
  ; cd ${LS_ROOT}/haskell/tmp \
  ; files="bin/haskell-language-server-${ghc_version} \
           bin/haskell-language-server-wrapper \
           lib/${ghc_version}" \
  ; sudo nu -c "'$files' | split row -r '\\s+' \
    | each {|x| if (\$x | path exists) { \
            let tg = ([.., (\$x | path dirname)] | path join); \
            mkdir \$tg; \
            cp -r \$x \$tg \
        } \
    }" \
  ; cd .. && sudo rm -rf tmp \
  ; find ${LS_ROOT}/haskell -type f -exec grep -IL . "{}" \; | xargs -L 1 sudo strip -s \
  ;

RUN set -eux \
  ; sudo stack install ${STACK_FLAGS} \
      ghcid implicit-hie haskell-dap ghci-dap haskell-debug-adapter \
      deepseq call-stack primitive ghc-prim \
      template-haskell aeson yaml  \
      classy-prelude base binary bytestring text \
      containers unordered-containers vector transformers \
      time directory filepath \
      shelly process unix \
      req websockets network servant wai warp network-uri \
      lens recursion-schemes free extensible-effects extensible-exceptions \
      megaparsec Earley \
      singletons \
      monad-par parallel async stm \
      regex-base regex-posix regex-compat \
      pipes conduit machines \
      QuickCheck falsify hspec \
      hmatrix linear \
      # statistics ad integration
      # parsers dimensional
      # scotty
      # http-conduit HTTP html taggy multipart \
      # optparse-applicative \
      # clock hpc pretty \
      # array hashtables dlist \
      # hashable  \
      # fixed mtl fgl \
      # boomerang \
      # bound unbound-generics transformers-compat \
      # syb uniplate \
      # persistent memory cryptonite \
      # mwc-random MonadRandom random \
      # katip monad-logger \
  ; sudo rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; opwd=$PWD \
  ; cd ~/world && stack new ${STACK_FLAGS} hello-rio rio && cd hello-rio && gen-hie > hie.yaml \
  ; cd ~/world && stack new ${STACK_FLAGS} hello-haskell && cd hello-haskell && gen-hie > hie.yaml \
  ; cd $opwd \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
  ; do sudo chmod 777 ${STACK_ROOT}/$x; done \
  ; sudo chmod -R 777 ${STACK_ROOT}/global-project

COPY _ghci /root/.ghci
