FROM ghcr.io/fj0r/io:root
ARG PIP_FLAGS="--break-system-packages"
ARG PIP_INDEX_PYTORCH="--index-url https://download.pytorch.org/whl/cpu"

ENV HOME=/home/master
ENV PATH=${HOME}/.local/bin:$PATH
ENV LANG=zh_CN.UTF-8

WORKDIR ${HOME}

ENV PORT=8080
EXPOSE $PORT

ENV HOST=0.0.0.0

### CONDA
ENV JUPYTER_ROOT=
ENV JUPYTER_PASSWORD=
ENV CONDA_HOME=/opt/conda
ENV PATH=${CONDA_HOME}/bin:$PATH
RUN set -ex \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      fontconfig fonts-noto-cjk fonts-noto-cjk-extra \
      fonts-arphic-ukai fonts-arphic-uming \
  ; fc-cache -fv \
  ; apt-get autoremove -y \
  ; apt-get clean -y \
  ; rm -rf /var/lib/apt/lists/* \
  ;

# RUN set -ex \
#   ; curl --retry 3 -fsSLo miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
#   ; bash ./miniconda.sh -b -p ${CONDA_HOME} \
#   ; rm ./miniconda.sh \
#   #; conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
#   #; conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
#   #; conda config --set show_channel_urls yes \
#   ; conda clean --all -f -y \
#   ; ln -s ${CONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
#   ; echo ". ${CONDA_HOME}/etc/profile.d/conda.sh" >> ~/.bashrc \
#   ; echo "conda activate base" >> ~/.bashrc \
#   ; conda update --all -y \
#   ##################### RUN set -ex \
#   ; conda install -y \
#       sqlite cloudpickle \
#       xz zlib zstd cryptography \
#       cffi zeromq libssh2 openssl pyzmq pcre \
#   ; conda clean --all -f -y \
#   ;

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} \
      psycopg[binary] lancedb \
      polars[all] numpy scikit-learn \
      httpx aiofile aiostream fastapi uvicorn \
      debugpy pytest pydantic pydantic-graph PyParsing \
      ipython typer pydantic-settings pyyaml \
      boltons decorator \
      pydantic-ai deltalake \
      marimo[recommended,lsp,sql] altair \
  ;

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} ${PIP_INDEX_PYTORCH} \
      torch torchtext torchvision torchaudio \
  ;


COPY entrypoint/marimo.sh /entrypoint/
CMD ["srv"]
USER master
