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
      libncurses-dev libtinfo-dev libblas-dev liblapack-dev \
      libcairo2-dev libpango1.0-dev libmagic-dev \
      # stack
      libicu-dev libffi-dev libgmp-dev zlib1g-dev \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*


### Racket
ENV RACKET_HOME=/opt/racket
ENV PATH=${RACKET_HOME}/bin:$PATH

RUN set -eux \
  ; racket_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/racket/racket/releases | jq -r '[.[]|select(.prerelease==false)][0].tag_name' | cut -c 2-) \
  ; racket_url=https://mirror.racket-lang.org/installers/${racket_ver}/racket-${racket_ver}-x86_64-linux-cs.sh \
  ; curl -sSLo racket.sh ${racket_url} \
  ; sh ./racket.sh --in-place --dest ${RACKET_HOME} \
  ; rm ./racket.sh \
  ; raco pkg install --deps search-auto --batch iracket \
  ; raco iracket install \
  ; rm -rf ${HOME}/.racket/download-cache

# ### GO
ENV GOROOT=/opt/go GOPATH=${HOME}/go
ENV PATH=${GOPATH}/bin:${GOROOT}/bin:$PATH
ENV GO111MODULE=on
RUN set -ex \
  ; cd /opt \
  ; GO_VERSION=$(curl https://golang.org/VERSION?m=text) \
  ; curl -sSL https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz \
      | tar xzf - \
  ; go get -u github.com/gopherdata/gophernotes \
  ; gophernotes_dir=${HOME}/.local/share/jupyter/kernels/gophernotes \
  ; mkdir -p $gophernotes_dir \
  ; cp "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes*/kernel/* $gophernotes_dir \
  ; chmod +w $gophernotes_dir/kernel.json \
  ; sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" < $gophernotes_dir/kernel.json.in > $gophernotes_dir/kernel.json \
  ; go get golang.org/x/tools/gopls@latest \
  ; rm -rf $(go env GOCACHE)/*

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

### iTorch
# RUN set -ex \
#   ; apt-get install lua5.3 luarocks software-properties-common \
#   ; git clone https://github.com/torch/distro.git ~/torch --recursive \
#   ; sed -i 's/python-software-properties/software-properties-common/g' ~/torch/install-deps \
#   ; cd ~/torch; bash install-deps \
#   ; ./install.sh \
#   ; apt-get install libzmq3-dev libssl-dev python-zmq luarocks \
#   ; git clone https://github.com/facebook/iTorch.git \
#   ; cd iTorch \
#   ; luarocks make

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
#  ; curl -Lo coursier https://git.io/coursier-cli && chmod +x coursier \
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
  ; curl https://sh.rustup.rs -sSf \
    | sh -s -- --default-toolchain stable -y \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  ; cargo install tomlq cargo-wasi wasm-pack cargo-prefetch \
  ; cargo prefetch \
      quicli structopt \
      actix actix-web \
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json \
      slog slog-async slog-json slog-term slog-logfmt \
      reqwest oxidizer nom handlebars \
      config chrono lru-cache itertools \
  ; cargo install evcxr_jupyter \
  ; evcxr_jupyter --install \
  ; rm -rf ${CARGO_HOME}/registry/src/*

RUN set -eux \
  ; mkdir -p /opt/language-server/rust \
  ; ra_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json"  https://api.github.com/repos/rust-analyzer/rust-analyzer/releases | jq -r '.[0].tag_name') \
  ; curl -sSL https://github.com/rust-analyzer/rust-analyzer/releases/download/${ra_version}/rust-analyzer-x86_64-unknown-linux-gnu.gz \
      | gzip -d > /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin










### Haskell
ENV STACK_ROOT=/opt/stack

ARG github_header="Accept: application/vnd.github.v3+json"
ARG github_api=https://api.github.com/repos
ARG stack_repo=commercialhaskell/stack

RUN set -ex \
  ; mkdir -p ${STACK_ROOT}/global-project && mkdir -p ${HOME}/.cabal \
  ; curl -sSL https://get.haskellstack.org/ | sh \
  ; git clone https://github.com/gibiansky/IHaskell \
  ; cd IHaskell \
  ; stack config set system-ghc --global false \
  ; stack config set install-ghc --global true \
  ; stack update && stack setup \
  # pip: 去掉版本号,使用已安装版本
  ; sed -i 's/==.*$//g' requirements.txt \
  ; pip --no-cache-dir install -r requirements.txt \
  ; stack install -j1 --fast \
  ; ${HOME}/.local/bin/ihaskell install --stack \
   # parsers boomerang criterion weigh arithmoi syb multipart HTTP html xhtml
  ; stack install -j1 --no-interleaved-output \
      # optparse-applicative taggy \
      shelly aeson yaml \
      monad-journal monad-logger \
      MonadRandom unix \
      # pipes \
      conduit machines mustache \
      # wreq scotty wai websockets warp
      http-conduit \
      # extensible-exceptions deepseq \
  #    hmatrix linear integration statistics \
      filepath directory pretty process singletons \
  #    monad-par async stm classy-prelude \
      # bound unbound-generics memory array \
      free extensible-effects  \
      # bytestring containers fgl \
      template-haskell time transformers attoparsec \
      # megaparsec mtl \
      QuickCheck \
      # parallel random call-stack \
      # text hashable unordered-containers vector zlib fixed \
      flow lens recursion-schemes \
  ; rm -rf ${STACK_ROOT}/programs/x86_64-linux/*.tar.xz \
  ; rm -rf ${STACK_ROOT}/pantry/hackage/* \
  ; stack new hello && rm -rf hello \
  ; yq e --inplace ".allow-different-user=true" ${STACK_ROOT}/config.yaml \
  ; for x in config.yaml \
             templates \
             stack.sqlite3.pantry-write-lock \
             pantry/pantry.sqlite3.pantry-write-lock \
             snapshots/x86_64-linux-tinfo6 \
  ; do chmod 777 ${STACK_ROOT}/$x; done \
  ; chmod -R 777 ${STACK_ROOT}/global-project \
  #; rm -rf ${HOME}/IHaskell/ \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -ex \
  ; echo "packages: []" > ${STACK_ROOT}/global-project/stack.yaml \
  ; yq ea --inplace "select(fi==0).resolver=select(fi==1).resolver | select(fi==0)" \
       ${STACK_ROOT}/global-project/stack.yaml ~/IHaskell/stack.yaml \
  ; cp ~/IHaskell/stack.yaml.lock ${STACK_ROOT}/global-project \
  ; stack install flow lens recursion-schemes \
  \
  ; mkdir -p /opt/language-server/haskell \
  ; hls_version=$(curl -sSL -H "Accept: application/vnd.github.v3+json"  https://api.github.com/repos/haskell/haskell-language-server/releases | jq -r '.[0].tag_name') \
  ; ghc_version=$(stack ghc -- --version | grep -oP 'version \K([0-9\.]+)') \
  ; curl -sSL https://github.com/haskell/haskell-language-server/releases/download/${hls_version}/haskell-language-server-wrapper-Linux.gz | gzip -d > /opt/language-server/haskell/haskell-language-server-wrapper \
  ; curl -sSL https://github.com/haskell/haskell-language-server/releases/download/${hls_version}/haskell-language-server-Linux-${ghc_version}.gz | gzip -d > /opt/language-server/haskell/haskell-language-server-${ghc_version} \
  ; chmod +x /opt/language-server/haskell/* \
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

# ENTRYPOINT [ "/usr/bin/tini", "--" ]
# CMD [ "jupyter", "lab", "--ip", "0.0.0.0"]