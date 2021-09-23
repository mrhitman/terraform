variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "name" {
  type = string
}

variable "onconnect_lambda" {
  description = "lambda for on websocket connect event"
}

variable "ondisconnect_lambda" {
  description = "lambda for on websocket connect event"
}

variable "onmessage_lambda" {
  description = "lambda for on websocket message event"
}

variable "tags" {
  type    = map(any)
  default = {}
}