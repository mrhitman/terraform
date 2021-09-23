output "invoke_url" {
  value = aws_apigatewayv2_stage.lambda.invoke_url
}
output "api_arn" {
  value = aws_apigatewayv2_api.websocket_api.execution_arn
}