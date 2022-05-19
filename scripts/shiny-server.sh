#!/bin/bash

# Make sure the directory for individual app logs exists
#mkdir -p /var/log/shiny-server
#chown shiny.shiny /var/log/shiny-server

if [ "$APPLICATION_LOGS_TO_STDOUT" != "false" ];
then
    # push the "real" application logs to stdout with multitail in detached mode
    /usr/local/bin/tailer.sh /var/log/shiny-server/ &
fi

# start shiny server
exec shiny-server 2>&1
