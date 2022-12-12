FROM fj0rd/io:ghcup as build

#RUN ghcup install hls
RUN set -eux \
  ; mkdir -p /opt/hls \
  ; ghcup compile hls --cabal-update -g master --ghc 9.2.5 \
  ; cp haskell-language-server* /opt/hls

FROM scratch

COPY --from=build /opt/hls /opt/language-server/haskell
