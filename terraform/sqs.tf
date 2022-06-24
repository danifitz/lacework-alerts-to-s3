resource "aws_sqs_queue" "lacework_alerts_queue" {
  name                      = var.aws_sqs_queue_name
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0
}

resource "aws_sqs_queue_policy" "lacework_alerts_queue_policy" {
  queue_url = aws_sqs_queue.lacework_alerts_queue.id


  # TODO: Fix Lambda principal ARN to the Lambda execution role AEN
  policy = <<POLICY
  {
  "Version": "2008-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "lacework_eventbridge_event_bus_sender_policy",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.lacework_alerts_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_cloudwatch_event_rule.lacework_alerts_eventbridge_event_rule.arn}"
        }
      }
    }
  ]
}
POLICY
}