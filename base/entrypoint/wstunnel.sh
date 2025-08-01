if [[ -n "$WSTUNNEL_PORT" ]] || [[ -n "$WSTUNNEL_PREFIX" ]]; then
    wstunnel server -r $WSTUNNEL_PREFIX ws://[::]:${WSTUNNEL_PORT:-9090} 2>&1 &

    echo -n "$! " | sudo tee -a /var/run/services > /dev/null
fi
