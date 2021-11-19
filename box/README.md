# SSHD
```bash
docker run \
    -p 2222:22 \
    -v <pubkey>:/etc/ssh/authorized_keys/root \
    fj0rd/io sshd
```

# Run as specify user:uid:gid
```bash
docker run -e user=dev:1000:1000 fj0rd/io
# or just
docker run -e user=dev fj0rd/io
```
