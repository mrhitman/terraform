variable "region" {
  default = "eu-central-1"
}

provider "aws" {
  region = var.region
}

resource "aws_sqs_queue" "terraform_queue" {
  name          = "terraform-example-queue"
  delay_seconds = 90
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.lambda_consumer.arn
}