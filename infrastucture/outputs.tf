output "device_out_sqs_url" {
  value = aws_sqs_queue.device_out.id
}

output "device_in_sqs_url" {
  value = aws_sqs_queue.device_in.id
}

output "wss_invoke_url" {
  value = module.api_gatewayv2.invoke_url
}

output "api_in_url" {
  value = "https://${aws_api_gateway_rest_api.device_in_to_sqs.id}.execute-api.${var.region}.amazonaws.com/send-command"
}