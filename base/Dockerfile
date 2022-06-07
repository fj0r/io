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
  ; cp /etc/apt/sources.list /etc/apt/sources.list.ustc \
  \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      sudo tmux procps htop cron logrotate tzdata \
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
  ; mkdir -p /etc/dropbear \
  \
  ; curl -sSL https://github.com/fj0r/configuration/raw/main/_tmux.conf -o /etc/skel/.tmux.conf \
  ; ln -fs /etc/skel/.tmux.conf /root/.tmux.conf \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; git clone --depth=1 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  \
  # :REMOVE:
  ; fd_url=$(curl -sSL https://api.github.com/repos/sharkdp/fd/releases -H 'Accept: application/vnd.github.v3+json' \
          | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${fd_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/fd' \
  ; yq_url=$(curl -sSL https://api.github.com/repos/mikefarah/yq/releases -H 'Accept: application/vnd.github.v3+json' \
          | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'linux_amd64.tar') \
  ; curl -sSL ${yq_url} | tar zxf - && mv yq_linux_amd64 /usr/local/bin/yq \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /world

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
