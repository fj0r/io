FROM debian:bullseye-slim as assets

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      ca-certificates curl jq binutils \
  ; mkdir -p /opt/assets \
  \
  ; xh_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ducaale/xh/releases | jq -r '.[0].tag_name') \
  ; curl -sSL https://github.com/ducaale/xh/releases/download/${xh_ver}/xh-${xh_ver}-x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /opt/assets --strip-components=1 \
  ; cd /opt/assets && ln -s ./xh ./xhs && ln -s ./xh /usr/local/bin \
  \
  ; btm_ver=$(xh https://api.github.com/repos/ClementTsang/bottom/releases Accept:application/vnd.github.v3+json | jq -r '[.[]|select(.prerelease == false)][0].tag_name') \
  ; xh -F https://github.com/ClementTsang/bottom/releases/download/${btm_ver}/bottom_x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /opt/assets btm \
  \
  ; yq_ver=$(xh https://api.github.com/repos/mikefarah/yq/releases Accept:application/vnd.github.v3+json | jq -r '.[0].tag_name') \
  ; xh -Fo /opt/assets/yq https://github.com/mikefarah/yq/releases/download/${yq_ver}/yq_linux_amd64 \
  ; chmod +x /opt/assets/yq \
  \
  ; fd_ver=$(xh https://api.github.com/repos/sharkdp/fd/releases Accept:application/vnd.github.v3+json | jq -r '[.[]|select(.prerelease == false)][0].tag_name') \
  ; xh -F https://github.com/sharkdp/fd/releases/download/${fd_ver}/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /opt/assets --strip-components=1 fd-${fd_ver}-x86_64-unknown-linux-musl/fd \
  \
  ; rg_ver=$(xh https://api.github.com/repos/BurntSushi/ripgrep/releases Accept:application/vnd.github.v3+json | jq -r '.[0].tag_name') \
  ; xh -F https://github.com/BurntSushi/ripgrep/releases/download/${rg_ver}/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /opt/assets --strip-components=1 ripgrep-${rg_ver}-x86_64-unknown-linux-musl/rg \
  \
  ; dust_ver=$(xh https://api.github.com/repos/bootandy/dust/releases Accept:application/vnd.github.v3+json | jq -r '.[0].tag_name') \
  ; xh -F https://github.com/bootandy/dust/releases/download/${dust_ver}/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /opt/assets --strip-components=1 dust-${dust_ver}-x86_64-unknown-linux-musl/dust \
  \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip




FROM debian:bullseye-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

COPY --from=assets /opt/assets /usr/local/bin
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      tzdata sudo jq \
      openssh-client rsync tcpdump socat \
      lsof inetutils-ping iproute2 nftables \
      xz-utils zstd zip unzip \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  #; sed -i /etc/locale.gen \
  #      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
  #      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  #; locale-gen \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
