FROM fj0rd/scratch:nu as utilities
FROM ubuntu:jammy
COPY --from=utilities / /
