# Lacework S3 alert channel

## What does this do?

Creates resources in AWS and Lacework to pipe alerts from Lacework via AWS Eventbridge to AWS S3 bucket.

The flows goes as so:

`Lacework -> AWS Eventbridge -> AWS SQS -> AWS Lambda function -> AWS S3 bucket`

The terraform module will create the following in your AWS account

1. AWS EventBridge Event Bus
2. AWS EventBridge Event Rule
3. AWS SQS Queue
4. AWS IAM role for Lambda function
5. AWS Lambda function to move JSON from SQS to S3
6. AWS S3 bucket to store the Alert JSON
7. Lacework event bridge alert channel

NOTE: You still need to attach a Lacework alert rule to the alert channel to route alerts to the channel.

## Terraform install

### Prequisites
Install the Lacework CLI and configure an API key. Install the AWS CLI.

1. Clone the repo
2. `cd terraform`
3. `terraform init`
4. `terraform plan/apply`

## Manual install

1. Create an [event bridge integration](https://docs.lacework.com/amazon-event-bridge#create-resources-within-your-aws-account)
2. Create a new Lambda function based on the `hello-world` blueprint. Copy the code from `index.js` into the new function
3. Edit the SQS Access Policy to enable the Lambda execution role to access it

```
{
    "Sid": "__receiver_statement",
    "Effect": "Allow",
    "Principal": {
    "AWS": "arn:aws:iam::<AWS_ACCOUNT_ID>:role/service-role/<LAMBDA_EXECUTION_ROLE_NAME>"
    },
    "Action": [
    "SQS:ChangeMessageVisibility",
    "SQS:DeleteMessage",
    "SQS:ReceiveMessage",
    "SQS:GetQueueAttributes"
    ],
    "Resource": "arn:aws:sqs:<YOUR_AWS_REGION>:<AWS_ACCOUNT_ID>:<SQS_QUEUE_NAME>"
}
```

4. Create a new S3 bucket where alerts will be sent.
5. In IAM add an inline policy to the Lambda execution role allowing it to write to S3 bucket

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "ExampleStmt",
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::<BUCKET_NAME>/*"
            ]
        }
    ]
}
```