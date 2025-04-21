FROM ghcr.io/fj0r/io
ARG PIP_FLAGS="--break-system-packages"

ENV LANG=zh_CN.UTF-8
ENV HOME=/root
ENV PATH=${HOME}/.local/bin:$PATH

WORKDIR ${HOME}

EXPOSE 8888

### CONDA
ENV JUPYTER_ROOT=
ENV JUPYTER_PASSWORD=
ENV CONDA_HOME=/opt/conda
ENV PATH=${CONDA_HOME}/bin:$PATH
COPY jupyter-config.py /
RUN set -ex \
  ; apt-get update \
  ; apt-get upgrade -y \
  ; DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
      fontconfig fonts-noto-cjk fonts-noto-cjk-extra \
      fonts-arphic-ukai fonts-arphic-uming \
  ; fc-cache -fv \
  ; apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/* \
  ;

RUN set -ex \
  ; curl --retry 3 -sSLo miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
  ; bash ./miniconda.sh -b -p ${CONDA_HOME} \
  ; rm ./miniconda.sh \
  #; conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ \
  #  && conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ \
  #  && conda config --set show_channel_urls yes \
  ; conda clean --all -f -y \
  ; ln -s ${CONDA_HOME}/etc/profile.d/conda.sh /etc/profile.d/conda.sh \
  ; echo ". ${CONDA_HOME}/etc/profile.d/conda.sh" >> ~/.bashrc \
  ; echo "conda activate base" >> ~/.bashrc \
  ; conda update --all -y \
  ; conda install -c conda-forge -y IPython ipykernel ipyparallel \
      jupyterlab jupyterlab-lsp \
  ##################### RUN set -ex \
  ; conda install -y \
      sqlite cloudpickle \
      xz zlib zstd cryptography \
      cffi zeromq libssh2 openssl pyzmq pcre \
  ; conda install -c pytorch -c nvidia \
      pytorch torchserve cudatoolkit \
      torchtext torchvision torchaudio \
  ; conda clean --all -f -y \
  ;

RUN set -ex \
  ; pip install --no-cache-dir ${PIP_FLAGS} \
      numpy scikit-learn polars \
      bokeh streamlit \
      httpx aiofile aiostream fastapi uvicorn \
      debugpy pytest pydantic PyParsing \
      ipython typer pydantic-settings pyyaml \
      boltons decorator \
      #pyiceberg[s3fs,pyarrow,pandas] \
  ; jupyter lab --generate-config \
  ; cat /jupyter-config.py >> $HOME/.jupyter/jupyter_lab_config.py \
  ;


RUN set -ex \
  #; jupyter labextension install @axlair/jupyterlab_vim \
  #; pip install --no-cache-dir ${PIP_FLAGS} --upgrade jupyterlab-git \
  #; jupyter lab build \
  #; jupyter serverextension enable --py jupyterlab_git \
  #; jupyter labextension install @jupyterlab/git \
  #; jupyter labextension install jupyterlab-drawio \
  ; rm -rf /usr/local/share/.cache/yarn \
  ; npm cache clean -f


COPY entrypoint/jupyter.sh /entrypoint/
CMD ["srv"]
