resource "lacework_alert_channel_aws_cloudwatch" "all_events" {
  name            = var.lacework_eventbridge_alert_channel_name
  event_bus_arn   = aws_cloudwatch_event_bus.lacework_alerts_eventbridge_event_bus.arn
  group_issues_by = "Events"
}