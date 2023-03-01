#!/usr/bin/env bash

set -e

if [[ "$DEBUG" == 'true' ]]; then
    set -x
fi

if [ ! -z "${PREBOOT}" ]; then
  bash $PREBOOT
fi


if [ -e /bin/zsh ]; then
    __shell=/bin/zsh
elif [ -e /bin/bash ]; then
    __shell=/bin/bash
else
    __shell=/bin/sh
fi

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


trap stop SIGINT SIGTERM

BASEDIR=$(dirname "$0")

source $BASEDIR/env.sh
source $BASEDIR/git.sh
source $BASEDIR/ssh.sh
source $BASEDIR/s3.sh
source $BASEDIR/cron.sh

if [ ! -z "${POSTBOOT}" ]; then
  bash $POSTBOOT
fi


if [ -z $1 ]; then
    if [ -e /usr/local/bin/nu ]; then
        __shell=/usr/local/bin/nu
    fi
    exec ${__shell}
elif [[ $1 == "srv" ]]; then
    sleep infinity &
    echo -n "$! " >> /var/run/services
    wait -n $(cat /var/run/services) && exit $?
else
    exec $@
fi
