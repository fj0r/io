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
  ; lldb_ver=$(lldb -v 2>/dev/null | rg 'lldb version ([0-9]+)\..*' -or '$1') \
  ; ln -sf /usr/bin/lldb-dap-${lldb_ver} /usr/bin/lldb-dap \
  ;

RUN set -eux \
  ; sccache_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/mozilla/sccache/releases/latest | jq -r '.tag_name') \
  ; curl --retry 3 -fsSL "https://github.com/mozilla/sccache/releases/download/${sccache_ver}/sccache-dist-${sccache_ver}-x86_64-unknown-linux-musl.tar.gz" \
  | tar zxf - --strip-components=1 -C /usr/local/bin --wildcards '*/sccache-dist' \
  ; curl --retry 3 -fsSL "https://github.com/mozilla/sccache/releases/download/${sccache_ver}/sccache-${sccache_ver}-x86_64-unknown-linux-musl.tar.gz" \
  | tar zxf - --strip-components=1 -C /usr/local/bin --wildcards '*/sccache' \
  ;

ENV RUSTC_WRAPPER=/usr/local/bin/sccache

RUN set -eux \
  ; curl --retry 3 -fsSL https://sh.rustup.rs \
    | sh -s -- --default-toolchain ${RUST_CHANNEL} -y --no-modify-path \
  ; rustup show active-toolchain || rustup toolchain install \
  ; rustup component add rust-src clippy rustfmt \
  ; rustup component add rust-analyzer \
  ; rustup target add x86_64-unknown-linux-musl \
  ; rustup target add wasm32-wasip1 wasm32-wasip2 wasm32-unknown-unknown \
  ; cargo install \
      cargo-pgo cargo-profiler cargo-bloat \
      cargo-expand cargo-eval cargo-tree \
      cargo-feature cargo-prefetch cargo-edit \
      cargo-wasi rust-script trunk \
      dioxus-cli \
      #cargo-leptos \
  ; cargo prefetch \
      clap figment tempdir \
      snafu anyhow thiserror \
      proc-macro2 syn quote macro_rules_attribute \
      nom linkme regex chrono moka \
      bon indoc refined_type itertools parking_lot \
      dashmap indexmap maplit arc-swap bitflags num \
      url reqwest scraper minijinja markdown \
      serde serde_derive serde_with serde_json_path \
      serde_json serde_cbor schemars toml serde_yaml \
      tracing tracing-subscriber tracing-serde \
      rayon polars nalgebra linfa burn \
      notify listenfd libc mimalloc \
      crossbeam wasmtime crb \
      tokio tokio-util tokio-tungstenite smol async-compat \
      futures futures-util async-stream async-trait \
      async-fs async-graphql sqlx \
      # warp async-graphql-warp \
      axum async-graphql-axum \
      # wasm-pack wee_alloc leptos \
      wasm-bindgen wasm-bindgen-futures wasm-logger \
      dioxus dioxus-web \
      sycamore gloo-net \
  ; rm -rf ${CARGO_HOME}/registry/src/* \
  ; chown master:master -R ${CARGO_HOME} \
  #; find ${CARGO_HOME}/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s
  ;

  #; mkdir -p ${LS_ROOT}/rust/bin \
  #; ra_url="https://github.com/rust-lang/rust-analyzer/releases/latest/download/rust-analyzer-x86_64-unknown-linux-gnu.gz" \
  #; curl --retry 3 -fsSL ${ra_url} | gzip -d > ${LS_ROOT}/rust/bin/rust-analyzer \
  #; chmod +x ${LS_ROOT}/rust/bin/rust-analyzer \
  #; strip -s ${LS_ROOT}/rust/bin/rust-analyzer \
RUN set -eux \
  #; { \
  #    echo '[build]' ;\
  #    echo 'target-dir = "/tmp/cargo/target"' ;\
  #  } | tee ${CARGO_HOME}/config.toml \
  ; opwd=$PWD; cd /world \
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
