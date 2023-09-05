ARG BASEIMAGE=fj0rd/io:common
FROM ${BASEIMAGE}

RUN set -eux \
  ; nu_ver=$(curl --retry 3 -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/latest/download/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${nu_url} | tar zxf - -C /usr/local/bin --strip-components=1 \
  ; rm -f /usr/local/bin/nu_plugin_example /usr/local/bin/README.txt /usr/local/bin/LICENSE \
  \
  ; zoxide_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${zoxide_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${zoxide_url} | tar zxf - -C /usr/local/bin zoxide \
  \
  ; find /usr/local/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ;
