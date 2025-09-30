variable "region" {
  description = "AWS region to deploy to"
  type        = string
  default     = "eu-central-1"
}

variable "name" {
  description = "Name prefix for the VPC"
  type        = string
  default     = "nikola-vujisic"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.42.0.0/16"
}

variable "tags" {
  description = "Additional resource tags"
  type        = map(string)
  default     = {}
}

variable "key_name" {
  description = "Existing EC2 key pair name for SSH"
  type        = string
  default     = null
}

variable "ssh_public_key" {
  type        = string
  description = "Your OpenSSH public key (ssh-ed25519 or ssh-rsa)"
  default     = ""
}