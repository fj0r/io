FROM fj0rd/io

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
    | sh -s -- --default-toolchain stable -y --no-modify-path \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasi wasm32-unknown-unknown wasm32-unknown-emscripten \
  ; cargo install \
      cargo-wasi wasm-pack wasm-bindgen-cli trunk \
      cargo-watch cargo-expand cargo-eval cargo-tree \
      cargo-feature cargo-prefetch cargo-generate \
  ; cargo prefetch \
      quicli structopt structopt-yaml \
      surf scraper handlebars \
      snafu thiserror anyhow lazy_static \
      proc-macro2 syn quote nom regex \
      tokio async-std async-graphql \
      warp async-graphql-warp \
      axum async-graphql-axum \
      wasm-bindgen wasm-bindgen-futures wasm-logger \
      yew yew-router wasm-bindgen reqwasm \
      # dioxus dioxus-web dioxus-html \
      serde serde_derive serde_yaml serde_json \
      serde_cbor apache-avro schemars \
      slog slog-async slog-json slog-term slog-logfmt \
      redis kafka polars linfa rayon \
      config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*
  #; find ${CARGO_HOME}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s

RUN set -eux \
  ; mkdir -p /opt/language-server/rust \
  ; ra_url=$(curl -sSL https://api.github.com/repos/rust-analyzer/rust-analyzer/releases -H 'Accept: application/vnd.github.v3+json' \
      | jq -r '[.[]|select(.prerelease==false)][0].assets[].browser_download_url' \
      | grep 'analyzer-x86_64-unknown-linux-gnu') \
  ; curl -sSL ${ra_url} | gzip -d > /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; strip -s /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin \
  \
  ; export USER=root \
  ; opwd=$PWD; cd /world \
  ; PROJ=hello-rust \
  ; cargo new $PROJ \
  ; cd $PROJ \
  ; cargo wasi build --release \
  ; rm -rf target \
  ; cd $opwd
