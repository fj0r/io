ARG BASEIMAGE=ghcr.io/fj0r/io:s3
FROM ${BASEIMAGE}

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /tmp/assets \
  ; cd /tmp/assets \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${btm_url} | tar zxf - -C /usr/local/bin btm \
  \
  ; bdwh_ver=$(curl --retry 3 -sSL https://api.github.com/repos/imsnif/bandwhich/releases/latest | jq -r '.tag_name') \
  ; bdwh_url="https://github.com/imsnif/bandwhich/releases/download/${bdwh_ver}/bandwhich-${bdwh_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${bdwh_url} | tar zxf - -C /usr/local/bin \
  \
  ; find /usr/local/bin -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;
