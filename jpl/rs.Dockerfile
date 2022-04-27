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
      yew yew-router wasm-bindgen \
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json serde_cbor apache-avro \
      slog slog-async slog-json slog-term slog-logfmt \
      polars rayon nom handlebars \
      config chrono lru-cache itertools \
  ; cargo install evcxr_jupyter \
  ; evcxr_jupyter --install \
  ; rm -rf ${CARGO_HOME}/registry/src/* \
  ; fd --search-path ${CARGO_HOME}/bin -t f -x strip -s {}

RUN set -eux \
  ; mkdir -p /opt/language-server/rust \
  ; ra_url=$(curl -sSL https://api.github.com/repos/rust-analyzer/rust-analyzer/releases -H 'Accept: application/vnd.github.v3+json' \
      | jq -r '[.[]|select(.prerelease==false)][0].assets[].browser_download_url' \
      | grep 'analyzer-x86_64-unknown-linux-gnu') \
  ; curl -sSL ${ra_url} | gzip -d > /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; strip -s /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin

