FROM fj0rd/io:ghcup

#RUN ghcup install hls
RUN set -eux \
  ; ghcup compile hls --cabal-update -g master --ghc 9.2.5

