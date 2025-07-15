ARG BASEIMAGE=ghcr.io/fj0r/io:root
FROM ${BASEIMAGE}

ENV PATH=/home/master/.moon/bin:$PATH

RUN set -eux \
  ; curl --retry 3 -fsSL https://cli.moonbitlang.com/install/unix.sh \
    | sudo -u master bash \
  ;
