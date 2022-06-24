resource "aws_lambda_function" "lacework_sqs_to_s3" {
  # If the file is not in the current working directory you will need to include a 
  # path.module in the filename.
  filename      = "${path.module}/../lambda.zip"
  function_name = "lacework_sqs_to_s3"
  role          = aws_iam_role.lacework_alerts_lambda_execution_role.arn
  handler       = "index.handler"

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${path.module}/../index.js")

  runtime = "nodejs12.x"
}

resource "aws_iam_role" "lacework_alerts_lambda_execution_role" {
  name = "lacework_lambda_execution_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lacework_alerts_lambda_execution_policy" {
  name        = "lacework_alerts_lambda_execution_role"
  path        = "/"
  description = "IAM policy for Lacework lambda function for passing alert data from sqs to s3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage",
        "SQS:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.lacework_alerts_queue.arn}",
      "Effect": "Allow"
    },
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "${aws_s3_bucket.lacework_alerts_bucket.arn}/*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda-role-policy-attach" {
  role       = aws_iam_role.lacework_alerts_lambda_execution_role.name
  policy_arn = aws_iam_policy.lacework_alerts_lambda_execution_policy.arn
}

resource "aws_lambda_event_source_mapping" "lacework-alerts-sqs-to-lambda" {
  event_source_arn = aws_sqs_queue.lacework_alerts_queue.arn
  function_name    = aws_lambda_function.lacework_sqs_to_s3.arn
}