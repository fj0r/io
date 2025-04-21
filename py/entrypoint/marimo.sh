marimo edit --no-token -p $PORT --host $HOST 2>&1 &
echo -n "$! " >> /var/run/services
