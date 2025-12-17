ARG BASEIMAGE=debian:sid-slim
FROM ghcr.io/fj0r/io:__dropbear__ AS dropbear

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
      sudo attr procps htop cron tzdata openssl \
      curl ca-certificates rsync tcpdump socat \
      sqlite3 jq patch tree logrotate \
      xz-utils zstd zip unzip \
      lsof inetutils-ping iproute2 iptables net-tools \
  \
  ; rg_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r '.tag_name') \
  ; rg_url="https://github.com/BurntSushi/ripgrep/releases/latest/download/ripgrep-${rg_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${rg_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/rg' \
  \
  ; fd_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/sharkdp/fd/releases/latest | jq -r '.tag_name') \
  ; fd_url="https://github.com/sharkdp/fd/releases/latest/download/fd-${fd_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  \
  ; wstun_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/erebe/wstunnel/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; wstun_url="https://github.com/erebe/wstunnel/releases/download/v${wstun_ver}/wstunnel_${wstun_ver}_linux_amd64.tar.gz" \
  ; curl --retry 3 -fsSL ${wstun_url} | tar zxf - -C /usr/local/bin wstunnel \
  ; chmod +x /usr/local/bin/wstunnel \
  \
  ; websocat_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/vi/websocat/releases/latest | jq -r '.tag_name') \
  ; websocat_url="https://github.com/vi/websocat/releases/download/${websocat_ver}/websocat.x86_64-unknown-linux-musl" \
  ; curl --retry 3 -fsSLo /usr/local/bin/websocat ${websocat_url} \
  ; chmod +x /usr/local/bin/websocat \
  \
  ; dua_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/Byron/dua-cli/releases/latest | jq -r '.tag_name') \
  ; dua_url="https://github.com/Byron/dua-cli/releases/download/${dua_ver}/dua-${dua_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${dua_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/dua' \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  #; sed -i /etc/locale.gen \
  #      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
  #      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  #; locale-gen \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  #; echo "Defaults env_keep += \"PATH\"" >> /etc/sudoers \
  \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;


ENV DEBUGE=
ENV PREBOOT=
ENV POSTBOOT=
ENV CRONFILE=
COPY entrypoint /entrypoint

ENV git_pull=
#ENV ed25519_xxx=

ENTRYPOINT [ "/entrypoint/init.sh" ]
