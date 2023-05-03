FROM fj0rd/io:jpl

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
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json serde_cbor apache-avro \
      slog slog-async slog-json slog-term slog-logfmt \
      polars rayon nom handlebars \
      config chrono lru-cache itertools \
  ; cargo install evcxr_jupyter \
  ; evcxr_jupyter --install \
  ; rm -rf ${CARGO_HOME}/registry/src/*
  #; find ${CARGO_HOME}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s

