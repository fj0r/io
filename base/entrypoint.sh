#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

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

init() {
    env | grep _ >> /etc/environment

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

    mkdir -p /etc/ssh/authorized_keys
    for i in "${!ed25519_@}"; do
        _AU=${i:8}
        eval "echo \"ssh-ed25519 \$$i\" >> /etc/ssh/authorized_keys/${_AU}"
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

    # Add users if SSH_USERS=user:uid:gid set
    if [ -n "${SSH_USERS}" ]; then
        USERS=$(echo $SSH_USERS | tr "," "\n")
        for U in $USERS; do
            IFS=':' read -ra UA <<< "$U"
            _NAME=${UA[0]}
            _UID=${UA[1]}
            _GID=${UA[2]}

            echo ">> Adding user ${_NAME} with uid: ${_UID}, gid: ${_GID}."
            if [ ! -e "/etc/ssh/authorized_keys/${_NAME}" ]; then
                echo "WARNING: No SSH authorized_keys found for ${_NAME}!"
            fi
            getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
            getent passwd ${_NAME} >/dev/null 2>&1 || useradd -r -m -p '' -u ${_UID} -g ${_GID} -s '' -c 'SSHD User' ${_NAME}
        done
    else
        # Warn if no authorized_keys
        if [ ! -e ~/.ssh/authorized_keys ] && [ ! $(ls -A /etc/ssh/authorized_keys) ]; then
            echo "WARNING: No SSH authorized_keys found!"
        fi
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

set_user () {
    if [ -n "${user}" ]; then
        IFS=':' read -ra UA <<< "$user"
        _NAME=${UA[0]}
        _UID=${UA[1]:-1000}
        _GID=${UA[2]:-1000}

        getent group ${_NAME} >/dev/null 2>&1 || groupadd -g ${_GID} ${_NAME}
        getent passwd ${_NAME} >/dev/null 2>&1 || useradd -m -u ${_UID} -g ${_GID} -G sudo -s /bin/bash -c 'Developer' ${_NAME}
    fi
}

if [[ $1 == "$DAEMON" ]]; then
    trap stop SIGINT SIGTERM
    init
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
    set_user
    if [ -n "${user}" ]; then
        #su - ${_NAME} -c "${CMD}"
        sudo -u ${_NAME} ${CMD}
    else
        exec ${CMD}
    fi
fi
