resource "aws_lambda_function" "device_out_metrics" {
  filename         = "../dist/lambdas/device-out-metrics.zip"
  function_name    = "device-out-metrics"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/device-out-metrics.zip")
  runtime          = var.node_runtime
  timeout          = 10
  memory_size      = 128
  tags             = var.tags
  environment {
    variables = {
      region = var.region
    }
  }
}

resource "aws_lambda_function" "device_in_commands" {
  filename         = "../dist/lambdas/device-in-commands.zip"
  function_name    = "device-in-commands"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/device-in-commands.zip")
  runtime          = var.node_runtime
  timeout          = 10
  memory_size      = 128
  tags             = var.tags
  environment {
    variables = {
      region    = var.region
      invokeUrl = module.api_gatewayv2.invoke_url
    }
  }
}

resource "aws_lambda_function" "on_connect" {
  filename         = "../dist/lambdas/on-connect.zip"
  function_name    = "on-connect"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/on-connect.zip")
  runtime          = var.node_runtime
  tags             = var.tags
  environment {
    variables = {
      region    = var.region
      endpoint  = aws_dynamodb_table.device_connections.id
      invokeUrl = module.api_gatewayv2.invoke_url
    }
  }
}

resource "aws_lambda_function" "on_disconnect" {
  filename         = "../dist/lambdas/on-disconnect.zip"
  function_name    = "on-disconnect"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/on-disconnect.zip")
  runtime          = var.node_runtime
  tags             = var.tags
  environment {
    variables = {
      region   = var.region
      endpoint = aws_dynamodb_table.device_connections.id
    }
  }
}

resource "aws_lambda_function" "on_message" {
  filename         = "../dist/lambdas/on-message.zip"
  function_name    = "on-message"
  role             = aws_iam_role.lambda_role.arn
  handler          = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/on-message.zip")
  runtime          = var.node_runtime
  tags             = var.tags
  environment {
    variables = {
      region   = var.region
      queueUrl = aws_sqs_queue.device_out.id
    }
  }
}