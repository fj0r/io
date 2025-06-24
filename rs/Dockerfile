ARG BASEIMAGE=ghcr.io/fj0r/io:root
FROM ${BASEIMAGE}

ARG RUST_CHANNEL=stable

ENV RUSTUP_HOME=/opt/rustup
ENV CARGO_HOME=/opt/cargo
ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
    valgrind \
    pkg-config libssl-dev lldb libxml2 \
    musl musl-dev musl-tools \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

RUN set -eux \
  ; sccache_ver=$(curl --retry 3 -sSL https://api.github.com/repos/mozilla/sccache/releases/latest | jq -r '.tag_name') \
  ; curl -sSL "https://github.com/mozilla/sccache/releases/download/${sccache_ver}/sccache-dist-${sccache_ver}-x86_64-unknown-linux-musl.tar.gz" \
  | tar zxf - --strip-components=1 -C /usr/local/bin --wildcards '*/sccache-dist' \
  ; curl -sSL "https://github.com/mozilla/sccache/releases/download/${sccache_ver}/sccache-${sccache_ver}-x86_64-unknown-linux-musl.tar.gz" \
  | tar zxf - --strip-components=1 -C /usr/local/bin --wildcards '*/sccache'

ENV RUSTC_WRAPPER=/usr/local/bin/sccache

RUN set -eux \
  ; curl --retry 3 -sSL https://sh.rustup.rs \
    | sh -s -- --default-toolchain ${RUST_CHANNEL} -y --no-modify-path \
  ; rustup show active-toolchain || rustup toolchain install \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup component add rust-analyzer \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasip1 wasm32-wasip2 wasm32-unknown-unknown \
  ; cargo install \
      cargo-pgo cargo-profiler \
      cargo-expand cargo-eval cargo-tree \
      cargo-feature cargo-prefetch \
      cargo-wasi rust-script trunk \
      dioxus-cli \
      #cargo-leptos \
  ; cargo prefetch \
      clap figment tempdir \
      notify listenfd libc \
      url reqwest scraper minijinja markdown \
      anyhow thiserror snafu \
      proc-macro2 syn quote macro_rules_attribute \
      nom linkme regex refined_type \
      crossbeam wasmtime crb \
      tokio tokio-tungstenite smol async-compat \
      async-fs async-graphql \
      # warp async-graphql-warp \
      axum async-graphql-axum \
      # wasm-pack wee_alloc leptos \
      wasm-bindgen wasm-bindgen-futures wasm-logger \
      dioxus dioxus-web \
      sycamore gloo-net \
      serde serde_derive serde_with serde_json_path \
      serde_json serde_cbor schemars \
      tracing tracing-subscriber tracing-serde \
      chrono lru-cache itertools \
      bitflags num fnv \
      ndarray polars rayon linfa burn \
  ; rm -rf ${CARGO_HOME}/registry/src/*
  #; find ${CARGO_HOME}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s

  #; mkdir -p ${LS_ROOT}/rust/bin \
  #; ra_url="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz" \
  #; curl --retry 3 -sSL ${ra_url} | gzip -d > ${LS_ROOT}/rust/bin/rust-analyzer \
  #; chmod +x ${LS_ROOT}/rust/bin/rust-analyzer \
  #; strip -s ${LS_ROOT}/rust/bin/rust-analyzer \
RUN set -eux \
  #; { \
  #    echo '[build]' ;\
  #    echo 'target-dir = "/tmp/cargo/target"' ;\
  #  } | tee ${CARGO_HOME}/config.toml \
  ; opwd=$PWD; cd /home/master/world \
  ; PROJ=hello-rust \
  ; cargo new $PROJ \
  ; cd $PROJ \
  #; cargo wasi build --release \
  ; cargo build --target=wasm32-wasip1 --release \
  ; rm -rf target \
  ; cd .. \
  ; chown master:master -R $PROJ \
  ; cd $opwd \
  ;
