#!/bin/bash

#Run this before UpdateUserPools-2nd.sh
AWS_COMMAND="aws cognito-idp list-user-pools --max-results 50"
unset NEXT_TOKEN

function parse_output() {
  if [ ! -z "$cli_output" ]; then
    echo $cli_output | jq -r '.UserPools[].Id' >> listOfUserPools.txt
    NEXT_TOKEN=$(echo $cli_output | jq -r ".NextToken")
  fi
}

cli_output=$($AWS_COMMAND)
parse_output

while [ "$NEXT_TOKEN" != "null" ]; do
  if [ "$NEXT_TOKEN" == "null" ] || [ -z "$NEXT_TOKEN" ] ; then
    echo "Command: $AWS_COMMAND "
    sleep 3
    cli_output=$($AWS_COMMAND)
    parse_output
  else
    echo "Next page: $AWS_COMMAND --next-token $NEXT_TOKEN"
    sleep 3
    cli_output=$($AWS_COMMAND --next-token $NEXT_TOKEN)
    parse_output
  fi
done

USER_POOL_IDS_COUNT=$(cat ./listOfUserPools.txt | wc -l)
printf "Done, $USER_POOL_IDS_COUNT user pool IDs have been appended to ./listOfUserPools.txt \
        \nPlease verify IDs match before moving on to the next script.\n"