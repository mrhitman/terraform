variable "region" {
  default = "eu-central-1"
}

variable "node_runtime" {
  default = "nodejs14.x"
}

variable "tags" {
  default = {
    env = "training-apigateway"
  }
}