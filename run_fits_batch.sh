#!/bin/bash --login

PID_FILE=/tmp/fits_batch.pid
MEDUSA_HOME=/services/medusa/medusa
export RAILS_ENV=production
export FITS_BATCH_SIZE=1000

if [[ -f $PID_FILE ]]; then
    echo "Existing PID file found"
#if pid file is present remove if the process doesn't appear to be running
    pid=$(cat $PID_FILE)
    process_info=$(ps -fp $pid)
    if [[ $process_info == *"run_fits_batch.sh"* ]]; then
	echo "Existing fits batch appears to be running. Exiting."
	exit 0
    else
	echo "Removing stale PID file"
	rm $PID_FILE
    fi
fi

cd $MEDUSA_HOME
echo "Running fits batch"
echo $$ > $PID_FILE
ionice -c2 -n6 -p $$
bundle exec rake fits:run_batch
rm $PID_FILE
exit 0
