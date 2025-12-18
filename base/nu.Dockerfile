ARG BASEIMAGE=ghcr.io/fj0r/io:s3
FROM ${BASEIMAGE}
ENV BUILD_DEPS="\
    gnupg2 binutils build-essential \
    cmake \
    "

RUN set -eux \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      git openssh-client ${BUILD_DEPS:-} \
  \
  ; git config --global pull.rebase false \
  ; git config --global init.defaultBranch main \
  ; git config --global user.name "unnamed" \
  ; git config --global user.email "unnamed@container" \
  \
  ; nu_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/nushell/nushell/releases/latest | jq -r '.tag_name') \
  ; nu_url="https://github.com/nushell/nushell/releases/download/${nu_ver}/nu-${nu_ver}-x86_64-unknown-linux-musl.tar.gz" \
  ; curl --retry 3 -fsSL ${nu_url} | tar zxf - -C /usr/local/bin --strip-components=1 --wildcards '*/nu' '*/nu_plugin_query' \
  \
  ; for x in nu nu_plugin_query \
  ; do strip -s /usr/local/bin/$x; done \
  \
  ; echo '/usr/local/bin/nu' >> /etc/shells \
  ; MASTER=master \
  ; useradd -mU -G sudo,root -s /usr/local/bin/nu $MASTER \
  ; mkdir -p /world \
  ; chown $MASTER:$MASTER -R /world \
  ; XDG_CONFIG_HOME=/home/${MASTER}/.config \
  ; mkdir -p $XDG_CONFIG_HOME \
  ; chown $MASTER:$MASTER -R $XDG_CONFIG_HOME \
  \
  ; git clone --depth=3 https://github.com/fj0r/nushell.git $XDG_CONFIG_HOME/nushell \
  ; opwd=$PWD; cd $XDG_CONFIG_HOME/nushell; git log -1 --date=iso; cd $opwd \
  ; chown $MASTER:$MASTER -R $XDG_CONFIG_HOME/nushell \
  ; sudo -u $MASTER nu -c "plugin add /usr/local/bin/nu_plugin_query" \
  ; echo '$env.NU_POWER_CONFIG.theme.color.normal = "xterm_olive"' >> /home/${MASTER}/.nu \
  ; chown $MASTER:$MASTER /home/${MASTER}/.nu \
  \
  # ; nvim_ver=$(curl --retry 3 -fsSL https://api.github.com/repos/neovim/neovim/releases/latest | jq -r '.tag_name') \
  # ; nvim_url="https://github.com/neovim/neovim/releases/download/${nvim_ver}/nvim-linux-x86_64.tar.gz" \
  # ; curl --retry 3 -fsSL ${nvim_url} | tar zxf - -C /usr/local --strip-components=1 \
  # ; strip -s /usr/local/bin/nvim \
  # ; git clone --depth=3 https://github.com/fj0r/nvim-lua.git $XDG_CONFIG_HOME/nvim \
  # ; opwd=$PWD; cd $XDG_CONFIG_HOME/nvim; git log -1 --date=iso; cd $opwd \
  # ; chown $MASTER:$MASTER -R $XDG_CONFIG_HOME/nvim \
  # ; sudo -u $MASTER nvim --headless "+Lazy! sync" +qa \
  # ; rm -rf $XDG_CONFIG_HOME/nvim/lazy/packages/*/.git \
  \
  ; apt-get purge -y --auto-remove ${BUILD_DEPS:-} \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

VOLUME /world
WORKDIR /world
