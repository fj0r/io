ARG BASEIMAGE=ghcr.io/fj0r/io:rust
FROM ${BASEIMAGE}

ENV PATH=/home/master/.moon/bin:$PATH

RUN set -eux \
  ; curl --retry 3 -fsSL https://cli.moonbitlang.com/install/unix.sh \
    | sudo -u master bash \
  ; cargo install wit-bindgen-cli --git https://github.com/peter-jerry-ye/wit-bindgen/ --branch moonbit \
  ; cargo install wasm-tools \
  ; cargo install wit-deps-cli \
  ;
