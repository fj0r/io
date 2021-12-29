#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
    sed -i /etc/ssh/sshd_config \
        -e 's!.*\(LogLevel\).*!\1 DEBUG!'
fi

DAEMON=sshd

print_fingerprints() {
    local BASE_DIR=${1-'/etc/ssh'}
    for item in rsa ecdsa ed25519; do
        echo ">>> Fingerprints for ${item} host key"
        ssh-keygen -E md5 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha256 -lf ${BASE_DIR}/ssh_host_${item}_key
        ssh-keygen -E sha512 -lf ${BASE_DIR}/ssh_host_${item}_key
    done
}

# Add users if $1=user:uid:gid set
set_user () {
    IFS=':' read -ra UA <<< "$1"
    _NAME=${UA[0]}
    _UID=${UA[1]:-1000}
    _GID=${UA[2]:-1000}

    getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
    getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s /bin/zsh -c "$2" ${_NAME}
}

init_ssh () {
    if [[ "${SSH_OVERRIDE_HOST_KEYS}" == "true" ]]; then
        rm -rf /etc/ssh/ssh_host_*
    fi
    # Generate Host keys, if required
    if ls /etc/ssh/ssh_host_* 1> /dev/null 2>&1; then
        echo ">> Host keys exist in default location"
        # Don't do anything
        print_fingerprints
    else
        echo ">> Generating new host keys"
        ssh-keygen -A
        print_fingerprints /etc/ssh
    fi

    if [ -n "$user" ]; then
        for u in $(echo $user | tr "," "\n"); do
            set_user ${u} 'SSH User'
        done
    fi

    mkdir -p /etc/ssh/authorized_keys
    for i in "${!ed25519_@}"; do
        _AU=${i:8}
        _HOME_DIR=$(getent passwd ${_AU} | cut -d: -f6)
        mkdir -p ${_HOME_DIR}/.ssh
        eval "echo \"ssh-ed25519 \$$i\" >> ${_HOME_DIR}/.ssh/authorized_keys"
        chown ${_AU} -R ${_HOME_DIR}/.ssh
        chmod go-rwx -R ${_HOME_DIR}/.ssh
    done

    # Fix permissions, if writable
    if [ -w ~/.ssh ]; then
        chown root:root ~/.ssh && chmod 700 ~/.ssh/
    fi
    if [ -w ~/.ssh/authorized_keys ]; then
        chown root:root ~/.ssh/authorized_keys
        chmod 600 ~/.ssh/authorized_keys
    fi
    if [ -w /etc/ssh/authorized_keys ]; then
        chown root:root /etc/ssh/authorized_keys
        chmod 700 /etc/ssh/authorized_keys
        find /etc/ssh/authorized_keys/ -type f -exec chmod 600 {} \;
    fi

    # Lock root account, if Disabled
    if [[ "${SSH_DISABLE_ROOT}" == "true" ]]; then
        echo "WARNING: root account is now locked. Unset SSH_DISABLE_ROOT to unlock the account."
    else
        usermod -p '' root
    fi

    # Update MOTD
    if [ -v MOTD ]; then
        echo -e "$MOTD" > /etc/motd
    fi
}


stop() {
    echo "Received SIGINT or SIGTERM. Shutting down $DAEMON"
    # Get PID
    pid=$(cat /var/run/$DAEMON/$DAEMON.pid)
    # Set TERM
    kill -SIGTERM "${pid}"
    # Wait for exit
    wait "${pid}"
    # All done.
    echo "Done."
}

env | grep _ >> /etc/environment

if [[ $1 == "$DAEMON" ]]; then
    trap stop SIGINT SIGTERM
    init_ssh
    /usr/sbin/sshd -D -e &
    pid="$!"
    mkdir -p /var/run/$DAEMON && echo "${pid}" > /var/run/$DAEMON/$DAEMON.pid
    wait "${pid}" && exit $?
else
    if [ -z $1 ]; then
        CMD="/bin/bash"
    else
        CMD="$@"
    fi
    if [ -n "${user}" ]; then
        set_user ${user} 'Developer'
        #su -p ${_NAME} -c "${CMD}"
        _envs=$(cat /etc/environment | awk -F '=' '{print $1}' | tr '\n' ',')
        sudo --preserve-env="${_envs}PATH" -u ${_NAME} ${CMD}
    else
        exec ${CMD}
    fi
fi
