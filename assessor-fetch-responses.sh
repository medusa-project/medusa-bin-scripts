#!/bin/bash --login
#fetch responses from the Medusa Assessor Service
# deprecated - included in fetch-messages

source $HOME/bin/env.sh

#fetch responses
( cd $MEDUSA_HOME ; bundle exec rake assessor:fetch_messages ; bundle exec rake assessor:handle_fetched_messages )

exit 0
