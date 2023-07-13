if [ -n "$NVIM_WORKDIR" ]; then
    nvim --listen 0.0.0.0:${NVIM_PORT:-1111} --headless ${NVIM_WORKDIR} 2>&1 &
    echo -n "$! " >> /var/run/services
fi
