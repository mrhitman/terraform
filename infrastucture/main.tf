provider "aws" {
  region = var.region
}

resource "aws_default_vpc" "default" {
}

resource "aws_sqs_queue" "device_out" {
  name                        = "device-out.fifo"
  fifo_queue                  = true
  delay_seconds               = 0
  content_based_deduplication = true
  tags                        = var.tags
}

resource "aws_lambda_event_source_mapping" "device_out_metrics_trigger" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.device_out.arn
  enabled          = true
  function_name    = aws_lambda_function.device_out_metrics.arn
}

resource "aws_sqs_queue" "device_in" {
  name                        = "device-in.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  delay_seconds               = 0
  tags                        = var.tags
}

resource "aws_lambda_event_source_mapping" "device_in_commands_trigger" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.device_in.arn
  enabled          = true
  function_name    = aws_lambda_function.device_in_commands.arn
}

