#!/bin/bash

echo "** Setting env variables**"
export DEFAULT_PROFILE=localstack-profile
export BUCKET_NAME=test-bucket
export HOST=http://localhost:4566
export REGION=eu-central-1
export SNS_TOPIC_NAME=sns-example-topic
export SQS_QUEUE_NAME=sqs-example-queue
export S3_NOTIFICATION_CONFIG_SETUP=notification.json

echo " "
echo "** setting aws dummy credentials **"
aws configure set aws_access_key_id "dummy" --profile $DEFAULT_PROFILE
aws configure set aws_secret_access_key "dummy" --profile $DEFAULT_PROFILE
aws configure set region $REGION --profile $DEFAULT_PROFILE
aws configure set output "table" --profile $DEFAULT_PROFILE

echo " "
echo "** Creating a SNS topic **"
aws --endpoint-url=$HOST sns create-topic --name $SNS_TOPIC_NAME --region $REGION --profile $DEFAULT_PROFILE --output table | cat

echo " "
echo "** Creating a SQS queue **"
aws --endpoint-url=$HOST sqs create-queue --queue-name $SQS_QUEUE_NAME --profile $DEFAULT_PROFILE --region $REGION --output table | cat

echo " "
echo "** Subscribing SQS queue to the SNS topic **"
aws --endpoint-url=$HOST sns subscribe --topic-arn arn:aws:sns:$REGION:000000000000:$SNS_TOPIC_NAME --profile $DEFAULT_PROFILE  --protocol sqs --notification-endpoint $HOST/000000000000/$SQS_QUEUE_NAME --output table | cat

echo " "
echo "** Creat a bucket **"
aws --endpoint-url=$HOST s3 mb s3://$BUCKET_NAME --output table | cat

echo " "
echo "** Subscribing sns to s3 trigger **"
aws --endpoint-url=$HOST s3api put-bucket-notification --bucket $BUCKET_NAME --notification-configuration file://$S3_NOTIFICATION_CONFIG_SETUP --output table | cat

echo " "
echo "*********** "
echo "*** DONE"
echo "** You can upload files to S3 and a message will be trigered to SNS topic, the you can read the message by using the SQS queue"