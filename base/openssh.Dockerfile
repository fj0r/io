FROM fj0rd/io:rs as rs

RUN set -eux \
  ; mkdir -p /opt/assets \
  ; git clone https://github.com/ogham/dog.git \
  ; cd dog \
  ; cargo build --release \
  ; mv target/release/dog /opt/assets \
  \
  #; cargo install flamegraph \
  #; mv $(whereis flamegraph | awk '{print $2}') /opt/assets \
  \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s


FROM debian:bullseye-slim as assets

COPY --from=rs /opt/assets /opt/assets/
RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      ca-certificates curl jq binutils xz-utils \
  ; mkdir -p /opt/assets \
  \
  ; xh_url=$(curl -sSL https://api.github.com/repos/ducaale/xh/releases -H 'Accept: application/vnd.github.v3+json' \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${xh_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/xh' \
  ; cd /opt/assets && ln -s ./xh ./xhs \
  ; cp /opt/assets/xh /usr/local/bin \
  \
  ; rq_url=$(curl -sSL https://api.github.com/repos/dflemstr/rq/releases -H 'Accept: application/vnd.github.v3+json' \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep 'x86_64-unknown-linux-gnu') \
  ; curl -sSL ${rq_url} | tar zxf - -C /opt/assets \
  \
  \
  ; fd_url=$(curl -sSL https://api.github.com/repos/sharkdp/fd/releases -H 'Accept: application/vnd.github.v3+json' \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${fd_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/fd' \
  \
  ; sd_url=$(curl -sSL https://api.github.com/repos/chmln/sd/releases -H 'Accept: application/vnd.github.v3+json' \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${sd_url} -o /opt/assets/sd && chmod +x /opt/assets/sd \
  \
  ; rg_url=$(curl -sSL https://api.github.com/repos/BurntSushi/ripgrep/releases -H 'Accept: application/vnd.github.v3+json' \
           | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${rg_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/rg' \
  \
  ; dust_url=$(curl -sSL https://api.github.com/repos/bootandy/dust/releases -H 'Accept: application/vnd.github.v3+json' \
             | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${dust_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/dust' \
  \
  ; just_url=$(curl -sSL https://api.github.com/repos/casey/just/releases -H 'Accept: application/vnd.github.v3+json' \
             | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${just_url} | tar zxf - -C /opt/assets just \
  \
  ; watchexec_url=$(curl -sSL https://api.github.com/repos/watchexec/watchexec/releases -H 'Accept: application/vnd.github.v3+json' \
                  | jq -r '[.[]|select(.prerelease==false and (.tag_name|startswith("cli")))][0].assets[].browser_download_url' | grep 'x86_64-unknown-linux-musl.tar') \
  ; curl -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /opt/assets --wildcards '*/watchexec' \
  \
  ; btm_url=$(curl -sSL https://api.github.com/repos/ClementTsang/bottom/releases -H 'Accept: application/vnd.github.v3+json' \
            | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep x86_64-unknown-linux-musl) \
  ; curl -sSL ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; websocat_url=$(curl -sSL https://api.github.com/repos/vi/websocat/releases -H 'Accept: application/vnd.github.v3+json' \
                  | jq -r '[.[]|select(.prerelease == false)][0].assets[].browser_download_url' | grep linux64) \
  ; curl -sSLo /opt/assets/websocat ${websocat_url} ; chmod +x /opt/assets/websocat \
  \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s




FROM debian:bullseye-slim

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    TIMEZONE=Asia/Shanghai

COPY --from=assets /opt/assets /usr/local/bin
RUN set -eux \
  ; cp /etc/apt/sources.list /etc/apt/sources.list.ustc \
  ; sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1mirrors.ustc.edu.cn\3main contrib non-free/g' /etc/apt/sources.list.ustc \
  \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      tzdata sudo jq rsync tcpdump socat \
      curl ca-certificates openssh-client openssh-server \
      lsof inetutils-ping iproute2 nftables net-tools \
      htop fuse xz-utils zstd zip unzip \
  \
  ; ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime \
  ; echo "$TIMEZONE" > /etc/timezone \
  #; sed -i /etc/locale.gen \
  #      -e 's/# \(en_US.UTF-8 UTF-8\)/\1/' \
  #      -e 's/# \(zh_CN.UTF-8 UTF-8\)/\1/' \
  #; locale-gen \
  ; sed -i 's/^.*\(%sudo.*\)ALL$/\1NOPASSWD:ALL/g' /etc/sudoers \
  \
  ; mkdir -p /var/run/sshd \
  ; sed -i /etc/ssh/sshd_config \
        #-e 's!.*\(AuthorizedKeysFile\).*!\1 /etc/ssh/authorized_keys/%u!' \
        -e 's!.*\(GatewayPorts\).*!\1 yes!' \
        -e 's!.*\(PasswordAuthentication\).*yes!\1 no!' \
  #; echo "HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub" >> /etc/ssh/sshd_config \
  ; echo "Match Address 10.0.0.0/8,172.17.0.0/16,192.168.0.0/16\n    PasswordAuthentication yes" \
        >> /etc/ssh/sshd_config \
  \
  #; mkdir -p /opt/helix \
  #; helix_url=$(curl -sSL https://api.github.com/repos/helix-editor/helix/releases -H 'Accept: application/vnd.github.v3+json' \
  #    | jq -r '.[0].assets[].browser_download_url' | grep x86_64-linux) \
  #; curl -sSL ${helix_url} | tar Jxf - -C /opt/helix --strip-components=1 \
  #; ln -sf /opt/helix/hx /usr/local/bin/h \
  #; mkdir -p /etc/skel/.config/helix && ln -sf /etc/skel/.config /root \
  #; curl -sSL https://raw.githubusercontent.com/fj0r/configuration/main/helix/config.toml > /etc/skel/.config/helix/config.toml \
  \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

WORKDIR /world

ENV SSH_DISABLE_ROOT=
ENV SSH_OVERRIDE_HOST_KEYS=

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
