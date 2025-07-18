ARG GHC_OS=ubuntu20.04
FROM ghcr.io/fj0r/io:root

ENV STACK_ROOT=/opt/stack GHC_ROOT=/opt/ghc
ENV PATH=${GHC_ROOT}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
        libicu-dev libffi-dev libgmp-dev zlib1g-dev \
        libncurses-dev libtinfo-dev libblas-dev liblapack-dev libnuma-dev \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; mkdir -p ${GHC_ROOT} \
  ; ghc_ver=$(curl --retry 3 -fsSL https://www.stackage.org/lts -H 'Accept: application/json' | jq -r '.snapshot.ghc') \
  ; ghc_url="https://downloads.haskell.org/~ghc/${ghc_ver}/ghc-${ghc_ver}-x86_64-${GHC_OS}-linux.tar.xz" \
  ; mkdir ghc_install \
  ; curl --retry 3 -fsSL ${ghc_url} \
  | tar Jxf - -C ghc_install --strip-components=1 \
  ; cd ghc_install \
  ; ./configure --prefix=${GHC_ROOT} \
  ; make install \
  ; cd .. \
  ; rm -rf ghc_install \
  \
  ; mkdir -p ${STACK_ROOT} \
  ; mkdir -p ${HOME}/.cabal \
  ; curl --retry 3 -fsSL https://get.haskellstack.org/ | sh \
  ; stack update \
  ; stack config set system-ghc --global true \
  ; stack config set install-ghc --global false \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | upsert allow-newer true | save -f ${STACK_ROOT}/config.yaml" \
  ;

RUN set -eux \
  ; git clone --depth=1 https://gitlab.haskell.org/ghc/ghc-wasm-meta.git \
  ; cd ghc-wasm-meta \
  ; ./setup.sh
