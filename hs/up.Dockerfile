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
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save -f ${STACK_ROOT}/config.yaml" \
  ;

COPY _ghci /root/.ghci
