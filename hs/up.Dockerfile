ARG GHC_OS=ubuntu20.04
FROM fj0rd/io

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
  ; curl --retry 3 -sSLo ${GHCUP_ROOT}/bin/ghcup https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup \
  ; chmod +x ${GHCUP_ROOT}/bin/ghcup \
  ; ghcup install stack \
  ; ghcup install cabal \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  \
  ; ghc_ver=$(curl --retry 3 -sSL https://www.stackage.org/lts -H 'Accept: application/json' | jq -r '.snapshot.ghc') \
  ; ghcup -s '["GHCupURL", "StackSetupURL"]' install ghc $ghc_ver \
  ; ghcup install hls \
  \
  ; for i in \
      tmp cache trash logs \
  ; do \
      du -hd 1 "${GHCUP_ROOT}/${i}" ;\
      rm -rf "${GHCUP_ROOT}/${i}/*" ;\
    done \
  \
  ; rm -rf ${GHCUP_ROOT}/ghc/${ghc_ver}/share \
  ; hls_ver=$(haskell-language-server-wrapper --numeric-version) \
  ; for i in \
    $(ls ${GHCUP_ROOT}/hls/${hls_ver}/lib/haskell-language-server-${hls_ver}/lib/) \
  ; do \
      if [ "$i" != "$ghc_ver" ]; then \
        rm -rf ${GHCUP_ROOT}/hls/${hls_ver}/lib/haskell-language-server-${hls_ver}/lib/$i; \
      fi ;\
    done \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save -f ${STACK_ROOT}/config.yaml" \
  ;

RUN set -eux \
  ; stack install \
      ghcid implicit-hie haskell-dap ghci-dap haskell-debug-adapter \
  ; rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; opwd=$PWD \
  ; cd /world && stack new ${STACK_FLAGS} ${STACK_RESOLVER} hello-rio rio && cd hello-rio && gen-hie > hie.yaml \
  ; cd /world && stack new ${STACK_FLAGS} ${STACK_RESOLVER} hello-haskell && cd hello-haskell && gen-hie > hie.yaml \
  ; cd $opwd \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project

COPY _ghci /root/.ghci
