FROM fj0rd/io

ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV STACK_HOME=/opt/stack GHCUP_HOME=/opt/ghcup
ENV PATH=${GHCUP_HOME}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p ${GHCUP_HOME}/bin \
  ; mkdir -p ${STACK_HOME} \
  #; curl -sSL https://get-ghcup.haskell.org | sh \
  ; curl -sSLo ${GHCUP_HOME}/bin/ghcup  https://downloads.haskell.org/~ghcup/x86_64-linux-ghcup \
  ; chmod +x ${GHCUP_HOME}/bin/ghcup \
  \
  ; ghcup install ghc \
  ; ghcup install stack \
  ; ghcup install cabal \
  #; rm -rf ${GHCUP_HOME}/cache \
  #; rm -rf ${GHCUP_HOME}/share/doc \
  \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  ; nu -c "open ${STACK_HOME}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save ${STACK_HOME}/config.yaml" \
  ;

COPY ghci /root/.ghci

#RUN set -eux \
#  ; ghcup install hls \
#  ; rm -rf ${GHCUP_HOME}/cache
#RUN set -eux \
#  ; ghcup compile hls --cabal-update -g master --ghc 9.2.5

