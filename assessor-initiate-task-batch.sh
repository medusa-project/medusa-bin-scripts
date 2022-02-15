#!/bin/bash --login
#fetch responses from the Medusa Assessor Service

source $HOME/bin/env.sh

#fetch responses
( cd $MEDUSA_HOME ; bundle exec rake assessor:initiate_task_batch )

exit 0
