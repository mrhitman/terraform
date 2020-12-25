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

resource "aws_lambda_function" "lambda_consumer" {
  filename         = "../dist/lambdas/lambda-consumer.zip"
  function_name    = "lambda-consumer"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/lambda-consumer.zip")
  runtime          = "nodejs12.x"
  timeout          = 30
  memory_size      = 128
  environment {
    variables = {
      region = var.region
      sqs    = aws_sqs_queue.terraform_queue.id
    }
  }
}

resource "aws_lambda_function" "lambda_emitter" {
  filename         = "../dist/lambdas/lambda-emitter.zip"
  function_name    = "lambda-emitter"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/lambda-emitter.zip")
  runtime          = "nodejs12.x"
  environment {
    variables = {
      region = var.region
      sqs    = aws_sqs_queue.terraform_queue.id
    }
  }
}

# Policies
resource "aws_iam_role" "lambda_role" {
  assume_role_policy = file("policy.json")
}

resource "aws_iam_policy" "lambda_policy" {
  policy = data.aws_iam_policy_document.policy_document.json
}

resource "aws_iam_role_policy_attachment" "policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role       = aws_iam_role.lambda_role.name
}

data "aws_iam_policy_document" "policy_document" {
  statement {
    sid       = "AllowSQSPermissions"
    effect    = "Allow"
    resources = ["arn:aws:sqs:*"]

    actions = [
      "sqs:ChangeMessageVisibility",
      "sqs:DeleteMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ReceiveMessage",
    ]
  }

  statement {
    sid       = "AllowInvokingLambdas"
    effect    = "Allow"
    resources = ["arn:aws:lambda:${var.region}:*:function:*"]
    actions   = ["lambda:InvokeFunction"]
  }

  statement {
    sid       = "AllowCreatingLogGroups"
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.region}:*:*"]
    actions   = ["logs:CreateLogGroup"]
  }

  statement {
    sid       = "AllowWritingLogs"
    effect    = "Allow"
    resources = ["arn:aws:logs:${var.region}:*:log-group:/aws/lambda/*:*"]

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
}

output "sqs_url" {
  value = aws_sqs_queue.terraform_queue.id
}