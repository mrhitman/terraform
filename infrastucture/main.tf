provider "aws" {
    region = "eu-central-1"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  assume_role_policy = file("./policy.json")
}

resource "aws_lambda_function" "test_lambda" {
  filename      = "../dist/lambdas/lambda1.zip"
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/lambda1.zip")
  runtime = "nodejs12.x"
}

resource "aws_lambda_function" "test_lambda2" {
  filename      = "../dist/lambdas/lambda2.zip"
  function_name = "lambda_function_name2"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "index.handler"
  source_code_hash = filebase64sha256("../dist/lambdas/lambda2.zip")
  runtime = "nodejs12.x"
}