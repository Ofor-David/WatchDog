variable "name_prefix" {
  description = "Prefix for all resources created"
  type        = string
}

variable "retention_in_days" {
  description = "Number of days to retain logs in CloudWatch Log Group"
  type        = number
}
