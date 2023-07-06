# SSHD
```bash
docker run \
    -p 2222:22 \
    -e ed25519_<root>='pubkey' \
    fj0rd/io srv
```

# Run as specify user:uid:gid
```bash
docker run -e user=dev:1000:1000 fj0rd/io
# or just
docker run -e user=dev fj0rd/io
```
