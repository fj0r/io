FROM ghcr.io/fj0r/io:root

ENV JULIA_HOME=/opt/julia
ENV PATH=${JULIA_HOME}/bin:$PATH
RUN set -eux \
  ; mkdir -p ${JULIA_HOME} \
  ; julia_ver=$(curl --retry 3 -fsSL https://julialang.org/downloads/ | rg 'Current stable release: v([.0-9]+)' -or '$1') \
  ; julia_ver_m=$(echo $julia_ver | cut -d'.' -f 1-2) \
  ; julia_url="https://julialang-s3.julialang.org/bin/linux/x64/${julia_ver_m}/julia-${julia_ver}-linux-x86_64.tar.gz" \
  ; curl --retry 3 -fsSL ${julia_url} | tar xz -C ${JULIA_HOME} --strip-components 1 \
  ; julia -e 'using Pkg; Pkg.add("LanguageServer"); Pkg.add("SymbolServer"); Pkg.add("StaticLint")' \
  ; julia -e 'using Pkg; Pkg.add("Genie"); Pkg.add("Flux"); Pkg.add("Gadfly")' \
  ; julia -e 'using Pkg; Pkg.add("IJulia"); using IJulia'
