ARG BASEIMAGE=ghcr.io/fj0r/io:latest
FROM ${BASEIMAGE}

RUN set -eux \
  ; curl -sSL https://cli.moonbitlang.com/binaries/latest/moonbit-linux-x86_64.tar.gz \
    | tar zxvf - --strip-components=1 -C /usr/local \
  ; chmod +x /usr/local/bin/moon* \
  ;
