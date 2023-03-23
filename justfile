test-entrypoint:
    podman run --rm -it --name test-entrypoint \
        --cap-add=SYS_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        -e https_proxy=http://172.178.5.21:7890 \
        -e ed25519_root=AAAAC3NzaC1lZDI1NTE5AAAAIK2Q46WeaBZ9aBkS3TF2n9laj1spUkpux/zObmliHUOI \
        -v $PWD/base/entrypoint:/entrypoint \
        io

test-entrypoint-s3:
    podman run --rm -it --name test-entrypoint \
        --cap-add=SYS_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
        -e https_proxy=http://172.178.5.21:7890 \
        -e ed25519_root=AAAAC3NzaC1lZDI1NTE5AAAAIK2Q46WeaBZ9aBkS3TF2n9laj1spUkpux/zObmliHUOI \
        -e s3_a=/srv/att,www-data,http://oss-cn-beijing-internal.aliyuncs.com,oss-cn-beijing,xxx,accesskey,secretkey \
        -e s3_b=/srv/att1,www-data,http://oss-cn-beijing-internal.aliyuncs.com,oss-cn-beijing,xxx,accesskey1,secretkey,nonempty \
        -e s3_c=/srv/att2,www-data,http://oss-cn-beijing-internal.aliyuncs.com,oss-cn-beijing,xxx,accesskey2,secretkey,nonempty,a=1,b=2 \
        -v $PWD/base/entrypoint:/entrypoint \
        io