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
  ; xh -F https://sh.rustup.rs \
    | sh -s -- --default-toolchain stable -y \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasi wasm32-unknown-unknown wasm32-unknown-emscripten \
  ; cargo install \
      cargo-wasi wasm-pack trunk wasm-bindgen-cli dioxus-cli \
      systemfd cargo-watch cargo-edit cargo-expand cargo-eval \
      cargo-tree cargo-feature cargo-prefetch cargo-generate \
  ; cargo prefetch \
      async-std quicli structopt surf \
      warp tokio async-graphql async-graphql-warp \
      yew yew-router wasm-bindgen \
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json \
      slog slog-async slog-json slog-term slog-logfmt \
      rayon nom handlebars \
      config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/* \
  ; find ${CARGO_HOME}/bin -type f -links 1 -exec grep -IL . "{}" \; | xargs -L 1 strip -s

RUN set -eux \
  ; mkdir -p /opt/language-server/rust \
  ; ra_url=$(xh https://api.github.com/repos/rust-analyzer/rust-analyzer/releases Accept:application/vnd.github.v3+json \
      | jq -r '[.[]|select(.prerelease==false)][0].assets[].browser_download_url' \
      | grep 'analyzer-x86_64-unknown-linux-gnu') \
  ; xh -F ${ra_url} | gzip -d > /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; strip -s /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin

RUN set -ex \
  ; export USER=root \
  ; cargo new hello-world \
  ; cd hello-world \
  ; cargo wasi build --release \
  ; cd .. \
  ; rm -rf hello-world
