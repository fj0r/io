FROM debian:bullseye-slim as assets

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      ca-certificates curl jq binutils \
  ; mkdir -p /opt/assets \
  \
  ; xh_url=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ducaale/xh/releases \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${xh_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/xh' \
  ; cd /opt/assets && ln -s ./xh ./xhs \
  ; cp /opt/assets/xh /usr/local/bin \
  \
  ; btm_url=$(xh https://api.github.com/repos/ClementTsang/bottom/releases Accept:application/vnd.github.v3+json \
            | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; xh -F ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; yq_url=$(xh https://api.github.com/repos/mikefarah/yq/releases Accept:application/vnd.github.v3+json \
           | jq -r '.[0].assets[].browser_download_url' | grep 'linux_amd64.tar') \
  ; xh -F ${yq_url} | tar zxf - && mv yq_linux_amd64 /opt/assets/yq \
  \
  ; fd_url=$(xh https://api.github.com/repos/sharkdp/fd/releases Accept:application/vnd.github.v3+json \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; xh -F ${fd_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/fd' \
  \
  ; rg_url=$(xh https://api.github.com/repos/BurntSushi/ripgrep/releases Accept:application/vnd.github.v3+json \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; xh -F ${rg_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/rg' \
  \
  ; dust_url=$(xh https://api.github.com/repos/bootandy/dust/releases Accept:application/vnd.github.v3+json \
             | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; xh -F ${dust_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/dust' \
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
