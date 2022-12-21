FROM fj0rd/io:jpl

### Haskell
ENV STACK_ROOT=/opt/stack
ENV IHASKELL_DATA_DIR=/opt/IHaskell

ARG github_api=https://api.github.com/repos
ARG stack_repo=commercialhaskell/stack

RUN set -eux \
  ; mkdir -p ${STACK_ROOT}/global-project && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  ; git clone --depth=1 https://github.com/gibiansky/IHaskell ${IHASKELL_DATA_DIR} \
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
  ; nu -c "open ${STACK_ROOT}/config.yaml | upsert allow-different-user true | save -f ${STACK_ROOT}/config.yaml" \
  ; stack install --no-interleaved-output \
      optparse-applicative shelly process unix \
      time clock hpc pretty filepath directory zlib \
      array hashtables dlist binary text \
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
  ; opwd=$PWD; cd /world \
  ; stack new hello-rio rio \
  ; stack new hello-haskell \
  ; cd $opwd \
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
          | save -f ${STACK_ROOT}/global-project/stack.yaml" \
  ; cp ${IHASKELL_DATA_DIR}/stack.yaml.lock ${STACK_ROOT}/global-project \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

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

