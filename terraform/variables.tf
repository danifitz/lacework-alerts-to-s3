###################################
# AWS variables
###################################
variable "aws_profile" {
  type = string
  default = "default"
}

variable "aws_region" {
  type = string
}

variable "aws_eventbridge_event_bus_name" {
  type = string
  default = "Lacework_Alerts_Event_Bus"
}

variable "aws_eventbridge_event_rule_name" {
  type = string
  default = "Lacework_Alerts_Event_Rule"
}

variable "aws_sqs_queue_name" {
  type = string
  default = "Lacework_Alerts_SQS_Queue_Name"
}

variable "aws_s3_bucket_name" {
  type = string
}

###################################
# Lacework variables
###################################
variable "lacework_profile" {
  type = string
  default = "default"
}

variable "lacework_eventbridge_alert_channel_name" {
  type = string
  default = "All events to AWS event-bus"
}

