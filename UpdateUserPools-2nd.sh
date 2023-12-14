#!/bin/bash

# Run QueryUserPoolsPagination-1st
USER_POOL_IDS=$(cat ./listOfUserPools.txt)
USER_POOL_IDS_COUNT=$(cat ./listOfUserPools.txt | wc -l)

# Paste properly formatted JSON into userpool-config.json, see example-userpool-config.json
sms_authentication_message=$(jq -r '.SmsAuthenticationMessage' userpool-config.json)
# verification-message-template
sms_verification_message=$(jq -r '.VerificationMessageTemplate.SmsMessage' userpool-config.json)
email_verification_message=$(jq -r '.VerificationMessageTemplate.EmailMessage' userpool-config.json)
email_verification_subject=$(jq -r '.VerificationMessageTemplate.EmailSubject' userpool-config.json)
# email-configuration
email_config_source_arn=$(jq -r '.EmailConfiguration.SourceArn' userpool-config.json)
email_config_sending_account=$(jq -r '.EmailConfiguration.EmailSendingAccount' userpool-config.json)
# sms-configuration
sms_config_sns_caller_arn=$(jq -r '.SmsConfiguration.SnsCallerArn' userpool-config.json)
sms_config_ext_id=$(jq -r '.SmsConfiguration.ExternalId' userpool-config.json)
sms_config_sns_region=$(jq -r '.SmsConfiguration.SnsRegion' userpool-config.json)
# admin-create-user-config
admin_config_allow_admin_create=$(jq -r '.AdminCreateUserConfig.AllowAdminCreateUserOnly' userpool-config.json)
admin_config_validity_days=$(jq -r '.AdminCreateUserConfig.UnusedAccountValidityDays' userpool-config.json)
# invite-message-template
invite_sms_message=$(jq -r '.AdminCreateUserConfig.InviteMessageTemplate.SMSMessage' userpool-config.json)
invite_email_message=$(jq -r '.AdminCreateUserConfig.InviteMessageTemplate.EmailMessage' userpool-config.json)
invite_email_subject=$(jq -r '.AdminCreateUserConfig.InviteMessageTemplate.EmailSubject' userpool-config.json)

for id in $USER_POOL_IDS
do
  echo "Updating parameters for User Pool: $id" | tee -a UpdateUserPools.log

  aws cognito-idp update-user-pool \
    --user-pool-id "$id" \
    --sms-authentication-message "$sms_authentication_message" \
    --verification-message-template "{
        \"SmsMessage\":\"$sms_verification_message\",
        \"EmailMessage\":\"$email_verification_message\",
        \"EmailSubject\":\"$email_verification_subject\"
    }" \
    --email-configuration "{
        \"SourceArn\":\"$email_config_source_arn\",
        \"EmailSendingAccount\":\"$email_config_sending_account\"
    }" \
    --sms-configuration "{
        \"SnsCallerArn\":\"$sms_config_sns_caller_arn\",
        \"ExternalId\":\"$sms_config_ext_id\",
        \"SnsRegion\":\"$sms_config_sns_region\"
    }" \
    --admin-create-user-config "{
        \"AllowAdminCreateUserOnly\":$admin_config_allow_admin_create,
        \"UnusedAccountValidityDays\":$admin_config_validity_days,
        \"InviteMessageTemplate\":{
            \"SMSMessage\":\"$invite_sms_message\",
            \"EmailMessage\":\"$invite_email_message\",
            \"EmailSubject\":\"$invite_email_subject\"
        }
    }"

  echo "Parameters updated for User Pool: $id" | tee -a UpdateUserPools.log
  sleep 1 # Prevent API throttling
done

printf "Done.\nParameters have been updated for $USER_POOL_IDS_COUNT User Pools.\n" | tee -a UpdateUserPools.log