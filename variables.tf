variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Check AWS Free Tier eligibility before deployment"
  type        = string
  default     = "t3.micro"
}

variable "instance_count" {
  description = "Exactly three instances, one in each AZ"
  type        = number
  default     = 3
  validation {
    condition     = var.instance_count == 3
    error_message = "This lab requires exactly three instances."
  }
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
