#!/bin/bash --login

source $HOME/bin/env.sh

PID_FILE=/tmp/fixity_batch.pid
export BATCH_SIZE=$FIXITY_BATCH_SIZE

if [[ -f $PID_FILE ]]; then
    echo "Existing PID file found"
#if pid file is present remove if the process doesn't appear to be running
    pid=$(cat $PID_FILE)
    process_info=$(ps -fp $pid)
    if [[ $process_info == *"run_fixity_batch.sh"* ]]; then
	echo "Existing fixity batch appears to be running. Exiting."
	exit 0
    else
	echo "Removing stale PID file"
	rm -f $PID_FILE
    fi
fi

cd $MEDUSA_HOME
echo "Running fixity batch"
echo $$ > $PID_FILE
ionice -c2 -n6 -p $$
bundle exec rake fixity:run_batch
rm -f $PID_FILE
exit 0
