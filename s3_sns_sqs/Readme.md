This is an example to send a S3 notification to SNS and a SQS queue is suscribed to the SNS topic

### Spin up the project
**Run the container in background**
```shell
docker-compose up -d
```

To check if the service is running
```shell
docker ps
## or you can use curl
curl http://localhost:4566
```

**configure the s3 services by running start.sh file**
```sh
sh start.sh
```

### The start.sh file will perform the below commands:
**Create a SNS topic**
```sh
aws --endpoint-url=http://localhost:4566 sns create-topic --name sns-example-topic --region eu-central-1 --profile test-profile --output table | cat
```

**Create a SQS queue**
```sh
aws --endpoint-url=http://localhost:4566 sqs create-queue --queue-name sqs-example-queue --profile test-profile --region eu-central-1 --output table | cat
```

**Subscribe SQS queue to the SNS topic**
```sh
aws --endpoint-url=http://localhost:4566 sns subscribe --topic-arn arn:aws:sns:eu-central-1:000000000000:sns-example-topic --profile test-profile  --protocol sqs --notification-endpoint http://localhost:4566/000000000000/sqs-example-queue --output table | cat
```

**create a bucket**
```sh
aws --endpoint-url=http://localhost:4566 s3 mb s3://test1
```

**subscribe sns to s3 trigger**
```sh
aws --endpoint-url=http://localhost:4566 s3api put-bucket-notification --bucket test1 --notification-configuration file://notification.json
````



Other commands:

To test the SNS and SQS integration:
Send messsages to SNS
```sh
aws sns publish --endpoint-url=http://localhost:4566 --topic-arn arn:aws:sns:eu-central-1:000000000000:sns-example-topic --message "Hello World" --profile test-profile --region eu-central-1 --output json | cat
```

Read messages from queue
```sh
aws --endpoint-url=http://localhost:4566 sqs receive-message --queue-url http://localhost:4566/000000000000/sqs-example-queue --profile test-profile --region eu-central-1 --output json | cat
```


To List the queues available
```sh
echo "########### Listing queues ###########"
aws --endpoint-url=http://localhost:4566 sqs list-queues
```

To check the trigger configuration
```sh
aws --endpoint-url=http://localhost:4566 s3api get-bucket-notification-configuration\
    --bucket test1
```

To Upload an object to the bucket to trigger the message to the SNS
```sh
aws --endpoint-url=http://localhost:4566 s3api put-object --bucket test1 --key index.html --body index.html
````


