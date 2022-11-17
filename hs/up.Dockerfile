FROM fj0rd/io

ENV BOOTSTRAP_HASKELL_NONINTERACTIVE=1
ENV GHC_ROOT=/opt/ghc GHCUP_INSTALL_BASE_PREFIX=${GHC_ROOT}
ENV PATH=${GHC_ROOT}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p ${GHC_ROOT} \
  ; curl -sSL https://get-ghcup.haskell.org | sh

COPY ghci /root/.ghci

RUN ghcup compile hls --cabal-update -g master --ghc 9.2.5

