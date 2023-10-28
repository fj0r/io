FROM fj0rd/io
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
        SciPy Numpy numpydoc Scikit-learn scikit-image Pandas numba \
        matplotlib-base seaborn Bokeh pyarrow \
        Statsmodels SymPy numexpr NLTK networkx \
        # Keras TensorFlow <PyMC>
        sqlite cloudpickle datashape \
        xz zlib zstd cryptography \
        cffi zeromq libssh2 openssl pyzmq pcre \
  ; conda clean --all -f -y \
  ; pip install --no-cache-dir ${PIP_FLAGS} \
        torch torchserve torchtext torchvision torchaudio pytorch-lightning \
        plotly_express pygwalker \
        debugpy fastapi uvicorn aiofile pytest \
        httpx typer hydra-core pyyaml deepmerge structlog \
        pydantic PyParsing decorator more-itertools cachetools \
        bash_kernel ipython-sql pgspecial jieba sh \
  ; python -m bash_kernel.install \
  ; jupyter lab --generate-config \
  ; cat /jupyter-config.py >> $HOME/.jupyter/jupyter_lab_config.py


RUN set -ex \
  #; jupyter labextension install @axlair/jupyterlab_vim \
  #; pip install --no-cache-dir ${PIP_FLAGS} --upgrade jupyterlab-git \
  #; jupyter lab build \
  #; jupyter serverextension enable --py jupyterlab_git \
  #; jupyter labextension install @jupyterlab/git \
  #; jupyter labextension install jupyterlab-drawio \
  ; rm -rf /usr/local/share/.cache/yarn \
  ; npm cache clean -f


### Julia
ENV JULIA_HOME=/opt/julia
ENV PATH=${JULIA_HOME}/bin:$PATH
RUN set -eux \
  ; mkdir -p ${JULIA_HOME} \
  ; julia_ver=$(curl --retry 3 -sSL https://julialang.org/downloads/ | rg 'Current stable release: v([.0-9]+)' -or '$1') \
  ; julia_ver_m=$(echo $julia_ver | cut -d'.' -f 1-2) \
  ; julia_url="https://julialang-s3.julialang.org/bin/linux/x64/${julia_ver_m}/julia-${julia_ver}-linux-x86_64.tar.gz" \
  ; curl --retry 3 -sSL ${julia_url} | tar xz -C ${JULIA_HOME} --strip-components 1 \
  ; julia -e 'using Pkg; Pkg.add("IJulia"); using IJulia'


COPY entrypoint/jupyter.sh /entrypoint/
CMD ["srv"]
