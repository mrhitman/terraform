module "api_gatewayv2" {
  name                = "websocket-api"
  source              = "./modules/apigateway_v2"
  onmessage_lambda    = aws_lambda_function.on_message
  onconnect_lambda    = aws_lambda_function.on_connect
  ondisconnect_lambda = aws_lambda_function.on_disconnect
  tags                = var.tags
}

data "aws_caller_identity" "current" {}

resource "aws_api_gateway_rest_api" "device_in_to_sqs" {
  name        = "device_in_to_sqs_gateway"
  description = "POST records to SQS queue"
}

resource "aws_api_gateway_resource" "send_command" {
  path_part   = "send-command"
  parent_id   = aws_api_gateway_rest_api.device_in_to_sqs.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.device_in_to_sqs.id
}

resource "aws_api_gateway_method" "send_command_post_method" {
  rest_api_id      = aws_api_gateway_rest_api.device_in_to_sqs.id
  resource_id      = aws_api_gateway_resource.send_command.id
  api_key_required = true
  http_method      = "POST"
  authorization    = "NONE"
}

// @TODO refactor 
resource "aws_iam_role" "apig-sqs-send-msg-role" {
  name = "apig-sqs-send-msg-role"
  tags = var.tags

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "apig-sqs-send-msg-policy" {
  name = "apig-sqs-send-msg-policy"
  tags = var.tags

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
           "Effect": "Allow",
           "Resource": [
               "*"
           ],
           "Action": [
               "logs:CreateLogGroup",
               "logs:CreateLogStream",
               "logs:PutLogEvents"
           ]
       },
       {
          "Effect": "Allow",
          "Action": "sqs:SendMessage",
          "Resource": "${aws_sqs_queue.device_in.arn}"
       }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "terraform_apig_sqs_policy_attach" {
  role       = aws_iam_role.apig-sqs-send-msg-role.id
  policy_arn = aws_iam_policy.apig-sqs-send-msg-policy.arn
}

resource "aws_api_gateway_integration" "device_in_sqs_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.device_in_to_sqs.id
  resource_id             = aws_api_gateway_resource.send_command.id
  http_method             = "POST"
  integration_http_method = "POST"
  type                    = "AWS"
  credentials             = aws_iam_role.apig-sqs-send-msg-role.arn
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${aws_sqs_queue.device_in.name}"
  passthrough_behavior    = "NEVER"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$input.body&MessageGroupId=$input.params().querystring.get(\"MessageGroupId\")"
  }
}

resource "aws_api_gateway_integration_response" "ir200" {
  rest_api_id       = aws_api_gateway_rest_api.device_in_to_sqs.id
  resource_id       = aws_api_gateway_resource.send_command.id
  http_method       = aws_api_gateway_method.send_command_post_method.http_method
  status_code       = 200
  selection_pattern = "^2[0-9][0-9]"

  response_templates = {
    "application/json" = "{\"message\": \"great success!\"}"
  }

  depends_on = [aws_api_gateway_integration.device_in_sqs_post_integration]
}

resource "aws_api_gateway_method_response" "mr200" {
  rest_api_id = aws_api_gateway_rest_api.device_in_to_sqs.id
  resource_id = aws_api_gateway_resource.send_command.id
  http_method = aws_api_gateway_method.send_command_post_method.http_method
  status_code = 200

  response_models = {
    "application/json" = "Empty"
  }

}