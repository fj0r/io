FROM fj0rd/io:jpl

### Haskell
ENV STACK_ROOT=/opt/stack
ENV IHASKELL_DATA_DIR=/opt/IHaskell

ARG github_api=https://api.github.com/repos
ARG stack_repo=commercialhaskell/stack

RUN set -eux \
  ; mkdir -p ${STACK_ROOT}/global-project && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  ; git clone https://github.com/gibiansky/IHaskell ${IHASKELL_DATA_DIR} \
  ; cd ${IHASKELL_DATA_DIR} \
  ; stack config set system-ghc --global false \
  ; stack config set install-ghc --global true \
  ; stack update && stack setup \
  # pip: 去掉版本号,使用已安装版本
  ; sed -i 's/==.*$//g' requirements.txt \
  ; pip --no-cache-dir install -r requirements.txt \
  ; stack install --fast \
  ; stack exec env | grep -v COLOR > ${IHASKELL_DATA_DIR}/env \
  ; export ihaskell_datadir=${IHASKELL_DATA_DIR} \
  ; ${HOME}/.local/bin/ihaskell install --stack --env-file ${IHASKELL_DATA_DIR}/env \
  # flow parsers boomerang criterion weigh arithmoi syb multipart HTTP html xhtml
  ; stack install --no-interleaved-output \
      optparse-applicative shelly process unix \
      time clock hpc pretty filepath directory zlib \
      array hashtables dlist binary bytestring text \
      containers hashable unordered-containers vector \
      deepseq call-stack primitive ghc-prim \
      template-haskell aeson yaml taggy stache \
      lens recursion-schemes fixed mtl fgl \
      parsers megaparsec Earley boomerang \
      free extensible-effects extensible-exceptions freer \
      bound unbound-generics transformers transformers-compat \
      uniplate singletons dimensional \
      monad-par parallel async stm classy-prelude \
      persistent memory \
      MonadRandom random \
      katip monad-logger monad-journal \
      pipes conduit machines \
      http-conduit wreq HTTP html websockets multipart \
      QuickCheck smallcheck hspec \
      hmatrix linear statistics integration \
  ; rm -rf ${STACK_ROOT}/programs/x86_64-linux/*.tar.xz \
  ; rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; rm -rf ${STACK_ROOT}/pantry/pantry.sqlite3* \
  ; stack new hello && rm -rf hello \
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | save ${STACK_ROOT}/config.yaml" \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
             snapshots/x86_64-linux-tinfo6 \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project \
  \
  ; echo "packages: []" > ${STACK_ROOT}/global-project/stack.yaml \
  ; nu -c "open ${STACK_ROOT}/global-project/stack.yaml \
          | upsert resolver (open ${IHASKELL_DATA_DIR}/stack.yaml | get resolver) \
          | save ${STACK_ROOT}/global-project/stack.yaml" \
  ; cp ${IHASKELL_DATA_DIR}/stack.yaml.lock ${STACK_ROOT}/global-project \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; mkdir -p /opt/language-server/haskell \
  #; hls_version=$(curl -sSL https://api.github.com/repos/haskell/haskell-language-server/releases -H 'Accept: application/vnd.github.v3+json' | jq -r '[.[]|select(.prerelease==false)][0].tag_name') \
  ; hls_version=$(curl https://downloads.haskell.org/~hls/ | rg -m 1 '>haskell-language-server-(.+)/<' -or '$1') \
  ; ghc_version=$(stack ghc -- --numeric-version) \
  ; curl -sSL https://downloads.haskell.org/~hls/haskell-language-server-${hls_version}/haskell-language-server-${hls_version}-x86_64-linux-deb10.tar.xz \
        | tar Jxvf - -C /opt/language-server/haskell --strip-components=1 \
          haskell-language-server-${hls_version}/bin/haskell-language-server-${ghc_version} \
          haskell-language-server-${hls_version}/bin/haskell-language-server-wrapper \
          haskell-language-server-${hls_version}/lib/${ghc_version} \
  ; find /opt/language-server/haskell -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; find /opt/language-server/haskell/bin -maxdepth 1 -type f | xargs -i ln -fs {} /usr/local/bin

COPY .ghci ${HOME}/.ghci

#RUN set -ex \
#  ; jupyter labextension install jupyterlab-ihaskell \
#  ; rm -rf /usr/local/share/.cache/yarn

# RUN set -ex \
#   ; jupyter labextension install jupyterlab-ihaskell \
#   ; rm -rf /usr/local/share/.cache/yarn

### misc
#RUN set -ex \
#  ; stack install flow \
#  ; stack repl

