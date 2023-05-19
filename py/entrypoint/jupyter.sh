echo "[$(date -Is)] starting jupyter-lab"

/opt/conda/bin/jupyter-lab 2>&1 &
echo -n "$! " >> /var/run/services
