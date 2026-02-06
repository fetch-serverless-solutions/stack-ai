variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "username" {
  type = string
}

variable "password" {
  type = string
  sensitive = true
}

variable "environment" {
  type = string
}

variable "sg_allow_from" {
  description = "List of security group ids allowed to connect to the DB"
  type        = list(string)
  default     = []
}
