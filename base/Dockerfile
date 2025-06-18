ARG BASEIMAGE=debian:bookworm-slim
FROM ghcr.io/fj0r/io:__dropbear__ as dropbear

FROM ${BASEIMAGE}

EXPOSE 22

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

COPY --from=dropbear / /
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      sudo procps htop cron tzdata openssl \
      curl ca-certificates rsync tcpdump socat \
      sqlite3 jq patch tree logrotate \
      xz-utils zstd zip unzip \
      lsof inetutils-ping iproute2 iptables net-tools \
  \
  ; rg_ver=$(curl --retry 3 -sSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; qjs_ver=$(curl -sSL https://bellard.org/quickjs/ | rg 'href="quickjs-([0-9\-]+).tar.xz"' -or '$1') \
  ; qjs_url="https://bellard.org/quickjs/binary_releases/quickjs-linux-x86_64-${qjs_ver}.zip" \
  ; mkdir out \
  ; cd out \
  ; curl --retry 3 -sSL ${qjs_url} -o a.zip \
  ; unzip a.zip \
  ; ./qjs -e 'print(Date())' \
  ; mv qjs /usr/local/bin/ \
  ; cd .. \
  ; rm -rf out \
  \
  ; fd_ver=$(curl --retry 3 -sSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; wstun_ver=$(curl --retry 3 -sSL https://api.github.com/repos/erebe/wstunnel/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; wstun_url="https://github.com/erebe/wstunnel/releases/download/v${wstun_ver}/wstunnel_${wstun_ver}_linux_amd64.tar.gz" \
  ; curl --retry 3 -sSL ${wstun_url} | tar zxf - -C /usr/local/bin wstunnel \
  ; chmod +x /usr/local/bin/wstunnel \
  \
  ; websocat_ver=$(curl --retry 3 -sSL https://api.github.com/repos/vi/websocat/releases/latest | jq -r '.tag_name') \
  ; websocat_url="https://github.com/vi/websocat/releases/download/${websocat_ver}/websocat.x86_64-unknown-linux-musl" \
  ; curl --retry 3 -sSLo /usr/local/bin/websocat ${websocat_url} \
  ; chmod +x /usr/local/bin/websocat \
  \
  ; dust_ver=$(curl --retry 3 -sSL https://api.github.com/repos/bootandy/dust/releases/latest | jq -r '.tag_name') \
  ; dust_url="https://github.com/bootandy/dust/releases/latest/download/dust-${dust_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${dust_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/dust' \
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


ENV DEBUGE=
ENV PREBOOT=
ENV POSTBOOT=
ENV CRONFILE=
COPY entrypoint /entrypoint

ENV git_pull=
#ENV ed25519_xxx=

ENTRYPOINT [ "/entrypoint/init.sh" ]
