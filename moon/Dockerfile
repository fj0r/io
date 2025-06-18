ARG BASEIMAGE=ghcr.io/fj0r/io:latest
FROM ${BASEIMAGE}

RUN set -eux \
  ; curl -sSL https://cli.moonbitlang.com/binaries/latest/moonbit-linux-x86_64.tar.gz \
    | sudo tar zxvf - --strip-components=1 -C /usr/local \
  ; sudo chmod +x /usr/local/bin/moon* \
  ;
