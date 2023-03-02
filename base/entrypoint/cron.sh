if [ ! -z "${CRONFILE}" ]; then
    crontab ${CRONFILE}
    cron
fi
