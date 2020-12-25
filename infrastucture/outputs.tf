output "sqs_url" {
  value = aws_sqs_queue.terraform_queue.id
}

output "lambda-emitter" {
  value = aws_lambda_function.lambda_emitter.function_name
}

output "lambda-consumer" {
  value = aws_lambda_function.lambda_consumer.function_name
}