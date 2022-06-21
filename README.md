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