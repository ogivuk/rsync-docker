#!/bin/sh

# rsync.sh - a script to configure the rsync job in the container

### PREPARATION

echo "Preparation steps started."

# should logs be created?
if [ "$RSYNC_LOG" != "" ]; then
    # logging enabled
    echo "Logging selected."
    # the specific name is to be used
    LOG_COMMAND=" >> /rsync/logs/$RSYNC_LOG"'.$(date +%Y%m%d-%H%M).log 2>&1'
    echo "Logging command is $LOG_COMMAND"
else
    # no logs
    echo "Logging NOT selected."
    LOG_COMMAND=""
fi

# run as a cron job?
if [ "$RSYNC_CRON" != "" ]; then
    # yes, run it as a cron job
    echo "Running rsync as a cron job selected."
    # make a crontab entry
    #shift
    echo "$RSYNC_CRON rsync $@$LOG_COMMAND" >> /etc/crontabs/root
    echo "Entry created in the crontab"
else
    # no cron job
    echo "Running rsync as a cron job NOT selected."
fi

echo "Preparation steps completed."

### EXECUTION

if [ "$RSYNC_CRON" != "" ]; then
    # run as a cron job, start the cron daemon
    echo "Starting the cron daemon..."
    crond -f
else
    # one time run
    echo "Executing rsync as an one time run..."
    eval rsync $@"$LOG_COMMAND"
fi
