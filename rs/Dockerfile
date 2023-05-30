ARG BASEIMAGE=fj0rd/io:go
FROM ${BASEIMAGE}

ARG RUST_CHANNEL=stable

ENV CARGO_HOME=/opt/cargo RUSTUP_HOME=/opt/rustup
ENV PATH=${CARGO_HOME}/bin:$PATH

RUN set -eux \
  ; apt-get update \
  ; apt-get install -y --no-install-recommends \
    pkg-config libssl-dev lldb libxml2 \
    musl musl-dev musl-tools \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

RUN set -eux \
  ; curl -sSL https://sh.rustup.rs \
    | sh -s -- --default-toolchain ${RUST_CHANNEL} -y --no-modify-path \
  ; rustup component add rust-src clippy rustfmt \
  #; rustup component add rust-analyzer \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasi wasm32-unknown-unknown \
  ; cargo install \
      cargo-wasi \
      cargo-watch cargo-expand cargo-eval cargo-tree \
      cargo-feature cargo-prefetch \
      #cargo-generate
      dioxus-cli \
  ; cargo prefetch \
      quicli structopt structopt-yaml \
      surf scraper handlebars \
      anyhow thiserror snafu lazy_static \
      proc-macro2 syn quote nom regex \
      tokio async-std async-graphql \
      warp async-graphql-warp \
      axum async-graphql-axum \
      wasm-bindgen wasm-bindgen-futures wasm-logger \
      # yew yew-router wasm-bindgen \
      dioxus dioxus-web dioxus-html reqwasm \
      serde serde_derive serde_yaml serde_json \
      serde_cbor apache-avro schemars \
      slog slog-async slog-json slog-term slog-logfmt \
      redis kafka polars linfa rayon \
      config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*
  #; find ${CARGO_HOME}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s

RUN set -eux \
  ; mkdir -p ${LS_ROOT}/rust/bin \
  ; ra_url="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz" \
  ; curl -sSL ${ra_url} | gzip -d > ${LS_ROOT}/rust/bin/rust-analyzer \
  ; chmod +x ${LS_ROOT}/rust/bin/rust-analyzer \
  ; strip -s ${LS_ROOT}/rust/bin/rust-analyzer \
  \
  #; export USER=root \
  ; opwd=$PWD; cd /world \
  ; PROJ=hello-rust \
  ; cargo new $PROJ \
  ; cd $PROJ \
  ; cargo wasi build --release \
  ; rm -rf target \
  ; cd $opwd
