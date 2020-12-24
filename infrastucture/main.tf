variable "region" {
  default = "eu-central-1"
}

provider "aws" {
  region = var.region
}

# data "aws_iam_policy_document" "example" {
#   statement {
#     actions   = ["*"]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_policy" "example" {
#   policy = data.aws_iam_policy_document.example.json
# }

resource "aws_sqs_queue" "terraform_queue" {
  name          = "terraform-example-queue"
  delay_seconds = 90
}

resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  batch_size       = 1
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  enabled          = true
  function_name    = aws_lambda_function.test_lambda.arn
}

resource "aws_lambda_function" "test_lambda" {
  filename         = "../dist/lambdas/lambda1.zip"
  function_name    = "lambda_function_name"
  role             = aws_iam_role.example_lambda.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/lambda1.zip")
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

resource "aws_lambda_function" "test_lambda2" {
  filename         = "../dist/lambdas/lambda2.zip"
  function_name    = "lambda_function_name2"
  role             = aws_iam_role.example_lambda.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/lambda2.zip")
  runtime          = "nodejs12.x"
  environment {
    variables = {
      region = var.region
      sqs    = aws_sqs_queue.terraform_queue.id
    }
  }
}

# Policies
resource "aws_iam_role" "example_lambda" {
  assume_role_policy = file("policy.json")
}



resource "aws_iam_policy" "example_lambda" {
  policy = data.aws_iam_policy_document.example_lambda.json
}

resource "aws_iam_role_policy_attachment" "example_lambda" {
  policy_arn = aws_iam_policy.example_lambda.arn
  role       = aws_iam_role.example_lambda.name
}

data "aws_iam_policy_document" "example_lambda" {
  statement {
    actions   = ["*"]
    resources = ["*"]
  }
}

# data "aws_iam_policy_document" "example_lambda" {
#   statement {
#     sid       = "AllowSQSPermissions"
#     effect    = "Allow"
#     resources = ["arn:aws:sqs:*"]

#     actions = [
#       "sqs:ChangeMessageVisibility",
#       "sqs:DeleteMessage",
#       "sqs:GetQueueAttributes",
#       "sqs:ReceiveMessage",
#     ]
#   }

#   statement {
#     sid       = "AllowInvokingLambdas"
#     effect    = "Allow"
#     resources = ["arn:aws:lambda:${var.region}:*:function:*"]
#     actions   = ["lambda:InvokeFunction"]
#   }

#   statement {
#     sid       = "AllowCreatingLogGroups"
#     effect    = "Allow"
#     resources = ["arn:aws:logs:${var.region}:*:*"]
#     actions   = ["logs:CreateLogGroup"]
#   }

#   statement {
#     sid       = "AllowWritingLogs"
#     effect    = "Allow"
#     resources = ["arn:aws:logs:${var.region}:*:log-group:/aws/lambda/*:*"]

#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]
#   }
# }

resource "aws_sns_topic" "results_updates" {
    name = "results-updates-topic"
}

output "sqs_url" {
  value = aws_sqs_queue.terraform_queue.id
}