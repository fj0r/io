FROM fj0rd/io:ghcup as build

#RUN ghcup install hls
RUN set -eux \
  ; mkdir -p /opt/hls/bin \
  ; ghcup compile hls --cabal-update -g master --ghc 9.2.5

#RUN set -eux \
#  ; cp ${GHCUP_ROOT}/bin/haskell-language-server* /opt/hls/bin
#
#FROM scratch
#
#COPY --from=build /opt/hls /opt/language-server/haskell
