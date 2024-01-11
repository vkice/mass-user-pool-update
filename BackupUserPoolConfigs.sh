#!/bin/bash

# Backing up each user pool configuration, can also be used as a starter for your userpool-config.json
# Also lots of unnecessary output, but might as well keep it all. See UserPoolsBackups.log
USER_POOL_IDS_COUNT=$(cat ./listOfUserPools.txt | wc -l)
USER_POOL_IDS=$(cat ./listOfUserPools.txt)

printf "\n---\nBacking up $USER_POOL_IDS_COUNT user pool configurations..\n---\n"

for id in $USER_POOL_IDS
do
  aws cognito-idp describe-user-pool --user-pool-id "$id" >> ./UserPoolsBackups.log
  sleep 0.1
  printf "Configuration backed up for User Pool: $id"
done

printf "Done, $USER_POOL_IDS_COUNT user pool IDs have been logged to ./UserPoolsBackups.log\n"