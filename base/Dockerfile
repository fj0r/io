ARG BASEIMAGE=ubuntu:latest
FROM fj0rd/scratch:dropbear as dropbear

FROM ${BASEIMAGE}

EXPOSE 22
VOLUME /world

ENV XDG_CONFIG_HOME=/etc \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

COPY --from=dropbear / /
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      sudo procps htop cron tzdata openssl \
      curl ca-certificates rsync tcpdump socat s3fs \
      jq patch tree logrotate \
      fuse xz-utils zstd zip unzip \
      lsof inetutils-ping iproute2 iptables net-tools \
  \
  ; fd_ver=$(curl -sSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; xh_ver=$(curl -sSL https://api.github.com/repos/ducaale/xh/releases/latest | jq -r '.tag_name') \
  ; xh_url="https://github.com/ducaale/xh/releases/latest/download/xh-${xh_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${xh_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/xh' \
  ; ln -sr /usr/local/bin/xh /usr/local/bin/xhs \
  \
  ; rg_ver=$(curl -sSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; templar_ver=$(curl -sSL https://api.github.com/repos/proctorlabs/templar/releases/latest | jq -r '.tag_name') \
  ; templar_url="https://github.com/proctorlabs/templar/releases/download/${templar_ver}/templar-x86_64-unknown-linux-musl.tar.xz" \
  ; curl -sSL ${templar_url} | tar Jxf - -C /usr/local/bin \
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

WORKDIR /world

ENV DEBUGE=
ENV PREBOOT=
ENV POSTBOOT=
ENV CRONFILE=
COPY entrypoint /entrypoint

ENV git_pull=
#ENV ed25519_xxx=

ENTRYPOINT [ "/entrypoint/init.sh" ]
