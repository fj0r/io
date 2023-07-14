if [ -n "$NVIM_WORKDIR" ]; then
    for p in /opt/* $LS_ROOT/* ; do
        if [ -d $p/bin ]; then
            export PATH=$p/bin:$PATH
        fi
    done

    if command -v stack &> /dev/null; then
        for l in $(find $(stack ghc -- --print-libdir) -maxdepth 1 -mindepth 1 -type d); do
            export LD_LIBRARY_PATH=$l:$LD_LIBRARY_PATH
        done
    fi

    export NVIM_SERVER=1

    nvim --listen 0.0.0.0:${NVIM_PORT:-1111} --headless ${NVIM_WORKDIR} 2>&1 &
    echo -n "$! " >> /var/run/services
fi
