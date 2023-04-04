FROM fj0rd/io:torch
ARG STACK_FLAGS="--local-bin-path=/usr/local/bin --no-interleaved-output"

RUN set -ex \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
      cmake build-essential \
      # racket
      libzmq5 \
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
  ; racket_ver=$(curl -sSL https://api.github.com/repos/racket/racket/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; racket_url="https://mirror.racket-lang.org/installers/${racket_ver}/racket-${racket_ver}-x86_64-linux-cs.sh" \
  ; curl -sSLo racket.sh ${racket_url} \
  ; sh ./racket.sh --in-place --dest ${RACKET_HOME} \
  ; rm ./racket.sh \
  ; raco pkg install --deps search-auto --batch iracket \
  ; raco iracket install \
  ; rm -rf ${HOME}/.racket/download-cache

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
#  ; stack install ${STACK_FLAGS} idris \
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
#  ; apt-get install -y --no-install-recommends openjdk-${JAVA_VERSION}-jdk-headless \
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
#  ; apt-get install -y --no-install-recommends leiningen \
#  ; apt-get clean \
#  ; git clone --depth=1 https://github.com/clojupyter/clojupyter \
#  ; cd clojupyter \
#  ; make \
#  ; make install \
#  ; rm -rf ${HOME}/.m2/repository/*


# ### iLua
# RUN set -ex \
#   ; apt-get update \
#   ; apt-get install -y --no-install-recommends \
#       lua5.3 luarocks lua-dkjson \
#   ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
#   ; cd /usr/bin && ln -fsr lua5.3 lua \
#   ; cd ${HOME} \
#   ; git clone --depth=1 https://github.com/guysv/ilua.git --recurse-submodules \
#   ; cd ilua \
#   ; pip --no-cache-dir install -e . --user \
#   ; python setup.py install_data -d ${HOME}/.local \
#   ; rm -rf ${HOME}/ilua/.git

COPY examples/* ./examples/
