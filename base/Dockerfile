FROM debian:bullseye-slim as assets

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      ca-certificates curl jq \
  ; xh_ver=$(curl -sSL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/ducaale/xh/releases | jq -r '.[0].tag_name') \
  ; curl -sSL https://github.com/ducaale/xh/releases/download/${xh_ver}/xh-${xh_ver}-x86_64-unknown-linux-musl.tar.gz \
    | tar zxf - -C /usr/local/bin --strip-components=1




FROM debian:bullseye-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai
ENV PYTHONUNBUFFERED=x

COPY --from=assets /usr/local/bin/xh /usr/local/bin
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      tzdata sudo \
      openssh-client jq rsync tcpdump socat \
      lsof inetutils-ping iproute2 nftables \
      htop procps tree xz-utils zstd zip unzip \
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
