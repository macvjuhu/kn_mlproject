variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-04b4f1a9cf54c11d0"
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
  default     = "t2.micro"
}

variable "keypair_name" {
  description = "The name of the keypair to use for the instance"
  type        = string
}

variable "my_public_subnet" {
  description = "The public network to allow access to the instance"
  type        = string
}

