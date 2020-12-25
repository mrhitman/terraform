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