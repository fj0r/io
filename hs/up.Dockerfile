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
  #; curl -sSL https://get-ghcup.haskell.org | sh \
  ; curl -sSLo ${GHCUP_ROOT}/bin/ghcup  https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup \
  ; chmod +x ${GHCUP_ROOT}/bin/ghcup \
  \
  ; ghcup install ghc \
  ; ghcup install stack \
  ; ghcup install cabal \
  #; rm -rf ${GHCUP_ROOT}/cache \
  #; rm -rf ${GHCUP_ROOT}/share/doc \
  \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save ${STACK_ROOT}/config.yaml" \
  ;

COPY ghci /root/.ghci

#RUN set -eux \
#  ; ghcup install hls \
#  ; rm -rf ${GHCUP_ROOT}/cache
#RUN set -eux \
#  ; ghcup compile hls --cabal-update -g master --ghc 9.2.5

