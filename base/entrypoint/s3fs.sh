# s3fs if s3_id=mount,user,endpoint,region,bucket,accesskey,secretkey,opts...
# opts: nonempty,a=1,b=2

set_s3 () {
    IFS=',' read -ra ARR <<< "$2"
    _mount=${ARR[0]}
    _user=${ARR[1]}
    _endpoint=${ARR[2]}
    _region=${ARR[3]}
    _bucket=${ARR[4]}
    _accesskey=${ARR[5]}
    _secretkey=${ARR[6]}

    _opt=""
    for i in ${ARR[@]:7}; do
        IFS='=' read -ra KV <<< $i
        if [ -z "${KV[1]}" ]; then
            _opt+="-o ${KV[0]} "
        else
            _opt+="-o $i "
        fi
    done

    _authfile=/.passwd-s3fs-${_mount////-}
    echo authfile  $_authfile

    echo "${_accesskey}:${_secretkey}" > $_authfile
    chmod go-rwx $_authfile
    chown $_user $_authfile
    mkdir -p $_mount
    chown $_user $_mount

    if [ -n "${_region}" ]; then
        _region="-o endpoint=$_region"
    else
        _region="-o use_path_request_style"
    fi
    cmd="sudo -u $_user -f $_opt -o bucket=$_bucket -o passwd_file=$_authfile -o url=$_endpoint $_region $_mount"
    echo $cmd
    eval $cmd &> /var/log/s3fs-${_mount////-} &
    echo -n "$! " >> /var/run/services
}

__s3=$(for i in "${!s3_@}"; do echo $i; done)
if [ -n "$__s3" ]; then
    for i in "${!s3_@}"; do
        _ID=${i:3}
        echo "[$(date -Is)] starting s3fs $_ID"
        _ARGS=$(eval "echo \$$i")
        set_s3 ${_ID} ${_ARGS}
    done
fi