resource "aws_cloudwatch_event_bus" "lacework_alerts_eventbridge_event_bus" {
  name = var.aws_eventbridge_event_bus_name
}

data "aws_iam_policy_document" "lacework_event_bus_policy_document" {
  statement {
    sid    = "allow_account_to_put_events"
    effect = "Allow"
    actions = [
      "events:PutEvents",
    ]
    resources = [
      aws_cloudwatch_event_bus.lacework_alerts_eventbridge_event_bus.arn
    ]

    principals {
      type        = "AWS"
      identifiers = ["434813966438"]
    }
  }
}

resource "aws_cloudwatch_event_bus_policy" "lacework_event_bus_policy" {
  policy         = data.aws_iam_policy_document.lacework_event_bus_policy_document.json
  event_bus_name = aws_cloudwatch_event_bus.lacework_alerts_eventbridge_event_bus.name
}

resource "aws_cloudwatch_event_rule" "lacework_alerts_eventbridge_event_rule" {
  name        = var.aws_eventbridge_event_rule_name
  description = "Capture each Lacework alert"
  event_bus_name = aws_cloudwatch_event_bus.lacework_alerts_eventbridge_event_bus.name

  event_pattern = <<EOF
{
  "account": ["434813966438"]
}
EOF
}

resource "aws_cloudwatch_event_target" "sqs" {
  rule      = aws_cloudwatch_event_rule.lacework_alerts_eventbridge_event_rule.name
  target_id = "SendToSQS"
  arn       = aws_sqs_queue.lacework_alerts_queue.arn
  event_bus_name = aws_cloudwatch_event_bus.lacework_alerts_eventbridge_event_bus.name
}