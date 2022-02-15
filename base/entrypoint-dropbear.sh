#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
    sed -i /etc/ssh/sshd_config \
        -e 's!.*\(LogLevel\).*!\1 DEBUG!'
fi

DAEMON=sshd

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
    if [ -n "$user" ]; then
        for u in $(echo $user | tr "," "\n"); do
            set_user ${u} 'SSH User'
        done
    fi

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
}


stop() {
    echo "Received SIGINT or SIGTERM. Shutting down"
    # Get PID
    pid=$(cat /var/run/services)
    # Set TERM
    kill -SIGTERM ${pid}
    # Wait for exit
    wait ${pid}
    # All done.
    echo -n '' > /var/run/services
    echo "Done."
}

env | grep -E '_|HOME|ROOT|PATH|VERSION|LANG|TIME|MODULE|BUFFERED' \
    | grep -Ev '^(_|HOME|USER)=' \
   >> /etc/environment

if [[ $1 == "$DAEMON" ]]; then
    trap stop SIGINT SIGTERM
    init_ssh
    /usr/sbin/dropbear -REFms -p 22 &
    pid="$!"
    echo "${pid}" >> /var/run/services
    wait -n "${pid}" && exit $?
else
    if [ -z $1 ]; then
        CMD="/bin/bash"
    else
        CMD="$@"
    fi
    if [ -n "${user}" ]; then
        set_user ${user} 'Developer'
        #su -p ${_NAME} -c "${CMD}"
        _envs=$(cat /etc/environment | awk -F '=' '{print $1}' | grep -v '^$' | paste -s -d"," -)
        sudo --preserve-env="${_envs}" -u ${_NAME} ${CMD}
    else
        exec ${CMD}
    fi
fi
