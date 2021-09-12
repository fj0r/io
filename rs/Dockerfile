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
  ; cargo install tomlq \
      cargo-wasi wasm-pack trunk wasm-bindgen-cli \
      systemfd cargo-watch cargo-edit cargo-feature cargo-prefetch \
  ; cargo prefetch \
      quicli structopt surf \
      tide async-std async-graphql async-graphql-tide \
      yew yew-router wasm-bindgen \
      thiserror anyhow \
      serde serde_derive serde_yaml serde_json \
      slog slog-async slog-json slog-term slog-logfmt \
      oxidizer nom handlebars \
      config chrono lru-cache itertools \
  ; rm -rf ${CARGO_HOME}/registry/src/*

RUN set -eux \
  ; mkdir -p /opt/language-server/rust \
  ; ra_version=$(xh https://api.github.com/repos/rust-analyzer/rust-analyzer/releases Accept:application/vnd.github.v3+json | jq -r '.[0].tag_name') \
  ; xh -F https://github.com/rust-analyzer/rust-analyzer/releases/download/${ra_version}/rust-analyzer-x86_64-unknown-linux-gnu.gz \
      | gzip -d > /opt/language-server/rust/rust-analyzer \
  ; chmod +x /opt/language-server/rust/rust-analyzer \
  ; ln -fs /opt/language-server/rust/rust-analyzer /usr/local/bin

RUN set -ex \
  ; export USER=root \
  ; cargo new hello-world \
  ; cd hello-world \
  ; cargo wasi build --release \
  ; cd .. \
  ; rm -rf hello-world
