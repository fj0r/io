FROM fj0rd/io:ghcup as build

#RUN ghcup install hls
RUN set -eux \
  ; ghcup compile hls --cabal-update -g master --ghc 9.2.5 \
  ; tar -cf - haskell-language-server* | zstd -T0 -19 > /opt/hls.tar.zst

FROM scratch

COPY --from=build /opt/hls.tar.zst /
