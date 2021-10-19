resource "aws_dynamodb_table" "device_connections" {
  name           = "device-connections"
  billing_mode   = "PROVISIONED"
  read_capacity  = 3
  write_capacity = 3
  hash_key       = "deviceId"
  range_key      = "connectionId"

  attribute {
    name = "deviceId"
    type = "S"
  }

  attribute {
    name = "connectionId"
    type = "S"
  }

  tags = var.tags
}