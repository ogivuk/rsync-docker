#!/bin/sh

# rsync.sh - a script to configure the rsync job in the container

### PREPARATION

echo "Preparation steps started."

# Create an account for rsync
## this is recommended when rsync is not asked to preserve file ownership
if [ "$RSYNC_UID" != "" ] && [ "$RSYNC_GID" != "" ]; then
    # UID and GID provided, create user
    echo "UID and GID provided: $RSYNC_UID and $RSYNC_GID. Creating the user"
    adduser -D -u $RSYNC_UID -g $RSYNC_GID rsyncuser
    RSYNC_USER=rsyncuser
else
    # UID and GID not provided
    echo "UID and GID are NOT provided. Proceeding as the root user."
    RSYNC_USER=root
fi

# run as a cron job?
if [ "$RSYNC_CRONTAB" != "" ]; then
    # using cron
    echo "Running rsync with cron and with a provided crontab selected."
    echo "The crontab file is expected to be at /rsync/$RSYNC_CRONTAB ."
    echo "Any provided rsync arguments will be ignored, specify them in the crontab file instead"
    # define the crontab file location
    crontab -u $RSYNC_USER /rsync/$RSYNC_CRONTAB
else
    # no cron job
    echo "Running rsync as a cron job NOT selected."
fi

echo "Preparation steps completed."

### EXECUTION

if [ "$RSYNC_CRONTAB" != "" ]; then
    # run as a cron job, start the cron daemon
    echo "Starting the cron daemon..."
    crond -f
else
    # one time run
    echo "Executing rsync as an one time run..."
    eval rsync $@
fi
