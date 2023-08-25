ARG BASEIMAGE=fj0rd/io:base

RUN set -eux \
  ; apt-get update \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends binutils \
  ; mkdir -p /opt/assets \
  \
  ; nu_ver=$(curl --retry 3 -sSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/latest/download/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${nu_url} | tar zxf - -C /opt/assets --strip-components=1 \
  ; rm -f /opt/assets/nu_plugin_example /opt/assets/README.txt /opt/assets/LICENSE \
  \
  ; zoxide_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ajeetdsouza/zoxide/releases/latest | jq -r '.tag_name' | cut -c 2-) \
  ; zoxide_url="https://github.com/ajeetdsouza/zoxide/releases/latest/download/zoxide-${zoxide_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${zoxide_url} | tar zxf - -C /opt/assets zoxide \
  \
  ; xh_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ducaale/xh/releases/latest | jq -r '.tag_name') \
  ; xh_url="https://github.com/ducaale/xh/releases/latest/download/xh-${xh_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${xh_url} | tar zxf - -C /opt/assets --strip-components=1 --wildcards '*/xh' \
  ; ln -sr /opt/assets/xh /opt/assets/xhs \
  \
  ; yq_url="https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64.tar.gz" \
  ; curl --retry 3 -sSL ${yq_url} | tar zxf - ./yq_linux_amd64 && mv yq_linux_amd64 /opt/assets/yq \
  \
  ; just_ver=$(curl --retry 3 -sSL https://api.github.com/repos/casey/just/releases/latest | jq -r '.tag_name') \
  ; just_url="https://github.com/casey/just/releases/latest/download/just-${just_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${just_url} | tar zxf - -C /opt/assets just \
  \
  ; watchexec_ver=$(curl --retry 3 -sSL https://api.github.com/repos/watchexec/watchexec/releases/latest  | jq -r '.tag_name' | cut -c 2-) \
  ; watchexec_url="https://github.com/watchexec/watchexec/releases/latest/download/watchexec-${watchexec_ver}-x86_64-unknown-linux-gnu.tar.xz" \
  ; curl --retry 3 -sSL ${watchexec_url} | tar Jxf - --strip-components=1 -C /opt/assets --wildcards '*/watchexec' \
  \
  ; btm_url="https://github.com/ClementTsang/bottom/releases/latest/download/bottom_x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${btm_url} | tar zxf - -C /opt/assets btm \
  \
  ; bdwh_ver=$(curl --retry 3 -sSL https://api.github.com/repos/imsnif/bandwhich/releases/latest | jq -r '.tag_name') \
  ; bdwh_url="https://github.com/imsnif/bandwhich/releases/download/${bdwh_ver}/bandwhich-v${bdwh_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -sSL ${bdwh_url} | tar zxf - -C /opt/assets \
  \
  ; pup_ver=$(curl --retry 3 -sSL https://api.github.com/repos/ericchiang/pup/releases/latest | jq -r '.tag_name') \
  ; pup_url="https://github.com/ericchiang/pup/releases/download/${pup_ver}/pup_${pup_ver}_linux_amd64.zip" \
  ; curl --retry 3 -sSL ${pup_url} -o pup.zip && unzip pup.zip && rm -f pup.zip && chmod +x pup && mv pup /opt/assets \
  \
  ; find /opt/assets -type f -exec grep -IL . "{}" \; | xargs -L 1 strip -s \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*
