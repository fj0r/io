FROM fj0rd/scratch:dropbear as dropbear
FROM fj0rd/scratch:nu as utilities

FROM ubuntu:jammy

EXPOSE 22
VOLUME /world

ENV XDG_CONFIG_HOME=/etc \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

COPY --from=dropbear / /
COPY --from=utilities / /
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      sudo procps htop cron logrotate tzdata \
      curl ca-certificates rsync tcpdump socat \
      git jq tree fuse xz-utils zstd zip unzip \
      lsof inetutils-ping iproute2 iptables net-tools \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  #; sed -i /etc/locale.gen \
  #      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
  #      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  #; locale-gen \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; mkdir -p /etc/dropbear \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; git clone --depth=1 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  ; git clone --depth=1 https://github.com/fj0r/zellij.git $XDG_CONFIG_HOME/zellij \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /world

ENV DEBUGE
ENV PREBOOT=
ENV POSTBOOT=
ENV CRONFILE=
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
