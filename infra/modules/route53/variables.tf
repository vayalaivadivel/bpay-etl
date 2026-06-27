variable "app_name" {
  type = string
}

variable "env" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "alb_dns_name" {
  type = string
}

variable "dns_records" {
  description = "DNS records to create"
  type        = map(string)
}

variable "create_hosted_zone" {
  description = "Whether to create Route53 Hosted Zone"
  type        = bool
  default     = true
}