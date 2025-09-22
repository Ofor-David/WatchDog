variable "name" {
  description = "Name of the application"
  type        = string  
}

variable "falco_bucket_arn"{
  description = "ARN of the S3 bucket containing Falco custom rules"
  type = string
}