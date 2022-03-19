FROM fj0rd/io:torch

RUN set -ex \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      cmake build-essential \
      # racket
      # libzmq5 \
      # rust
      libzmq3-dev pkg-config libssl-dev \
      # debug
      lldb libxml2 \
      # haskell
      python3-dev python3-wheel \
      libncurses-dev libtinfo-dev libblas-dev liblapack-dev libnuma-dev \
      libcairo2-dev libpango1.0-dev libmagic-dev \
      # stack
      libicu-dev libffi-dev libgmp-dev zlib1g-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


### Racket
ENV RACKET_HOME=/opt/racket
ENV PATH=${RACKET_HOME}/bin:$PATH

RUN set -eux \
  ; racket_ver=$(curl -sSL https://api.github.com/repos/racket/racket/releases -H 'Accept: application/vnd.github.v3+json' | jq -r '[.[]|select(.prerelease==false)][0].tag_name' | cut -c 2-) \
  ; racket_url=https://mirror.racket-lang.org/installers/${racket_ver}/racket-${racket_ver}-x86_64-linux-cs.sh \
  ; curl -sSLo racket.sh ${racket_url} \
  ; sh ./racket.sh --in-place --dest ${RACKET_HOME} \
  ; rm ./racket.sh \
  ; raco pkg install --deps search-auto --batch iracket \
  ; raco iracket install \
  ; rm -rf ${HOME}/.racket/download-cache

# ### GO
# ENV GOROOT=/opt/go GOPATH=${HOME}/go
# ENV PATH=${GOPATH}/bin:${GOROOT}/bin:$PATH
# ENV GO111MODULE=on
# RUN set -ex \
#   ; cd /opt \
#   ; GO_VERSION=$(curl -sSL https://golang.org/VERSION m==text) \
#   ; curl -sSL https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz \
#       | tar xzf - \
#   ; go get -u github.com/gopherdata/gophernotes \
#   ; gophernotes_dir=${HOME}/.local/share/jupyter/kernels/gophernotes \
#   ; mkdir -p $gophernotes_dir \
#   ; cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes*/kernel/* $gophernotes_dir \
#   ; chmod +w $gophernotes_dir/kernel.json \
#   ; sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < $gophernotes_dir/kernel.json.in > $gophernotes_dir/kernel.json \
#   ; go get golang.org/x/tools/gopls@latest \
#   ; rm -rf $(go env GOCACHE)/*

### idris
#ENV IDRIS_ROOT=${HOME}/idris
#RUN set -ex \
#  ; mkdir -p ${IDRIS_ROOT} \
#  ; printf "\
#flags: {}\n\
#extra-package-dbs: []\n\
#packages: []\n\
#resolver: ${STACKAGE_VERSION}\n\
#extra-deps:\n\
#  - binary-0.8.7.0\n\
#  - Cabal-2.2.0.1\n\
#  - aeson-1.3.1.1\n\
#  - code-page-0.1.3\n\
#  - containers-0.5.11.0\n\
#  - megaparsec-6.5.0\n\
#  - network-2.7.0.2\n\
#  - zip-archive-0.3.3\n\
#" > ${IDRIS_ROOT}/stack.yaml \
#  ; cd ${IDRIS_ROOT} \
#  ; stack install idris \
#  #; rm -rf ${STACK_ROOT}/global-project/.stack-work/install/x86_64-linux/${STACKAGE_VERSION}/8.6.5/lib/* \
#  ; rm -rf ${STACK_ROOT}/indices/*

### ocaml
#ENV OPAMROOT=/opt/opam OPAMROOTISOK=1 OPAMVERSION=2.0.4
#ENV PATH=${OPAMROOT}/default/bin:$PATH
#RUN set -ex \
#  ; apt-get install -y --no-install-recommends m4 bubblewrap libcairo2-dev && apt-get clean \
#  ; curl -sSLo /usr/local/bin/opam https://github.com/ocaml/opam/releases/download/${OPAMVERSION}/opam-${OPAMVERSION}-x86_64-linux \
#  ; chmod +x /usr/local/bin/opam \
#  #; sudo sysctl kernel.unprivileged_userns_clone=1 \
#  ; opam init -a --disable-sandboxing \
#  ; opam install -y "cairo2<0.6" \
#  ; opam install -y jupyter \
#  ; opam install -y jupyter-archimedes \
#  ; opam install -y higher \
#  ; jupyter kernelspec install --name ocaml-jupyter "$(opam config var share)/jupyter" \
#  ; rm -rf ${OPAMROOT}/download-cache/*

### scala
#ENV JAVA_VERSION=11 JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64 \
#    SCALA_HOME=/opt/scala SCALA_VERSION=2.12.8 ALMOND_VERSION=0.5.0
#ENV PATH=${SCALA_HOME}/bin:$PATH
#RUN set -ex \
#  ; mkdir -p /usr/share/man/man1 \
#  ; mkdir -p ${SCALA_HOME} \
#  ; apt-get -y --no-install-recommends install openjdk-${JAVA_VERSION}-jdk-headless \
#  ; apt-get clean \
#  ; curl -sSL https://downloads.lightbend.com/scala/$SCALA_VERSION/scala-$SCALA_VERSION.tgz \
#      | tar xzf - -C ${SCALA_HOME} --strip-components=1  \
#  ; curl -sSLo coursier https://git.io/coursier-cli && chmod +x coursier \
#  ; ./coursier bootstrap \
#      -r jitpack \
#      -i user -I user:sh.almond:scala-kernel-api_$SCALA_VERSION:$ALMOND_VERSION \
#      sh.almond:scala-kernel_$SCALA_VERSION:$ALMOND_VERSION \
#      -o almond \
#  ; ./almond --install
#  #; rm -rf ${HOME}/.cache/coursier/*

### clojure
#RUN set -ex \
#  ; apt-get -y --no-install-recommends install leiningen \
#  ; apt-get clean \
#  ; git clone https://github.com/clojupyter/clojupyter \
#  ; cd clojupyter \
#  ; make \
#  ; make install \
#  ; rm -rf ${HOME}/.m2/repository/*










### Rust
ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -eux \
  # /opt/cargo/registry/index/github.com-*/.cargo-index-lock
  ; curl -sSL https://sh.rustup.rs \
    | sh -s -- --default-toolchain stable -y --no-modify-path \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  ; cargo install tomlq cargo-wasi wasm-pack cargo-prefetch \
  ; cargo prefetch \
      async-std quicli structopt surf \
      warp tokio async-graphql async-graphql-warp \
      yew yew-router wasm-bindgen \
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json \
      slog slog-async slog-json slog-term slog-logfmt \
      polars rayon nom handlebars \
      config chrono lru-cache itertools \
  ; cargo install evcxr_jupyter \
  ; evcxr_jupyter --install \
  ; rm -rf ${CARGO_HOME}/registry/src/* \
  ; find ${CARGO_HOME}/bin -type f -links 1 -exec grep -IL . "{}" \; | xargs -L 1 strip -s

RUN set -eux \
  ; mkdir -p /opt/language-server/rust \
  ; ra_url=$(curl -sSL https://api.github.com/repos/rust-analyzer/rust-analyzer/releases -H 'Accept: application/vnd.github.v3+json' \
      | jq -r '[.[]|select(.prerelease==false)][0].assets[].browser_download_url' \
      | grep 'analyzer-x86_64-unknown-linux-gnu') \
  ; curl -sSL ${ra_url} | gzip -d > /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; strip -s /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin










### Haskell
ENV STACK_ROOT=/opt/stack
ENV IHASKELL_DATA_DIR=/opt/IHaskell

ARG github_api=https://api.github.com/repos
ARG stack_repo=commercialhaskell/stack

RUN set -ex \
  ; mkdir -p ${STACK_ROOT}/global-project && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  #; IHASKELL_DATA_DIR=${HOME}/IHaskell \
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
   # parsers boomerang criterion weigh arithmoi syb multipart HTTP html xhtml
  ; stack install --no-interleaved-output \
      optparse-applicative shelly process unix \
      time clock hpc pretty filepath directory zlib \
      array hashtables dlist binary bytestring text \
      containers hashable unordered-containers vector \
      deepseq call-stack primitive ghc-prim \
      template-haskell aeson yaml taggy stache \
      flow lens recursion-schemes fixed mtl fgl \
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
  ; yq e --inplace ".allow-different-user=true" ${STACK_ROOT}/config.yaml \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
             snapshots/x86_64-linux-tinfo6 \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project \
  \
  ; echo "packages: []" > ${STACK_ROOT}/global-project/stack.yaml \
  ; yq ea --inplace "select(fi==0).resolver=select(fi==1).resolver | select(fi==0)" \
       ${STACK_ROOT}/global-project/stack.yaml ${IHASKELL_DATA_DIR}/stack.yaml \
  ; cp ${IHASKELL_DATA_DIR}/stack.yaml.lock ${STACK_ROOT}/global-project \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -ex \
  ; mkdir -p /opt/language-server/haskell \
  ; hls_assets=$(curl -sSL https://api.github.com/repos/haskell/haskell-language-server/releases -H 'Accept: application/vnd.github.v3+json' | jq -c '[[.[]|select(.prerelease==false)][0].assets[].browser_download_url]') \
  ; ghc_version=$(stack ghc -- --numeric-version) \
  ; curl -sSL $(echo $hls_assets | jq -r '.[]' | grep 'wrapper-Linux') | gzip -d > /opt/language-server/haskell/haskell-language-server-wrapper \
  ; curl -sSL $(echo $hls_assets | jq -r '.[]' | grep "Linux-${ghc_version}") | gzip -d > /opt/language-server/haskell/haskell-language-server-${ghc_version} \
  ; chmod +x /opt/language-server/haskell/* \
  ; find /opt/language-server/haskell -type f -links 1 -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; for l in /opt/language-server/haskell/*; do ln -fs $l /usr/local/bin; done

COPY .ghci ${HOME}/.ghci

#RUN set -ex \
#  ; jupyter labextension install jupyterlab-ihaskell \
#  ; rm -rf /usr/local/share/.cache/yarn










# RUN set -ex \
#   ; jupyter labextension install jupyterlab-ihaskell \
#   ; rm -rf /usr/local/share/.cache/yarn

# ### iLua
# RUN set -ex \
#   ; apt-get update \
#   ; apt-get install -y --no-install-recommends \
#       lua5.3 luarocks lua-dkjson \
#   ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
#   ; cd /usr/bin && ln -fsr lua5.3 lua \
#   ; cd ${HOME} \
#   ; git clone https://github.com/guysv/ilua.git --recurse-submodules \
#   ; cd ilua \
#   ; pip --no-cache-dir install -e . --user \
#   ; python setup.py install_data -d ${HOME}/.local \
#   ; rm -rf ${HOME}/ilua/.git


COPY examples/* ./examples/

### misc
#RUN set -ex \
#  ; stack install flow \
#  ; stack repl

