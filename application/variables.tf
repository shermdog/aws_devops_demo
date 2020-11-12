variable "dd_api_key" {
  type        = string
  description = "Datadog Agent API key"
}

variable "db_password" {
  type        = string
  description = "Database password for application"
  default = "postgres"
}

variable "r53_zone" {
  type        = string
  description = "Route 53 DNS Zone"
}

variable "r53_domain" {
  type        = string
  description = "Route 53 domain"
}

variable "services" {
  type = map(object({
    framework                 = string,
    high_error_rate_warning   = number,
    high_error_rate_critical  = number,
    high_avg_latency_warning  = number,
    high_avg_latency_critical = number,
    high_p90_latency_warning  = number,
    high_p90_latency_critical = number,
  }))
  description = "Services and query alert thresholds"
}

locals {
  env = split("-", terraform.workspace)[0]
  hostname = local.env == "production" ? "prod" : terraform.workspace
  domain = var.r53_domain
}

variable "app_version" {
  type        = number
  description = "Version of app to deploy [1-3]"
}

variable "monitors" {
  type        = bool
  description = "Create monitors [true/false]"
}

variable "frontend_version" {
  type = map
default = {
    1 = "shermdog/datadog-ecommerce-ecs:store-frontend-broken-instrumented"
    2 = "shermdog/datadog-ecommerce-ecs:store-frontend-fixed-instrumented"
    3 = "shermdog/datadog-ecommerce-ecs:store-frontend-fixed-instrumented"
  }
}

variable "discounts_version" {
  type = map
default = {
    1 = "shermdog/datadog-ecommerce-ecs:discounts-n1"
    2 = "shermdog/datadog-ecommerce-ecs:discounts-n1"
    3 = "shermdog/datadog-ecommerce-ecs:discounts-fixed"
  }
}

variable "ads_version" {
  type = map
default = {
    1 = "shermdog/datadog-ecommerce-ecs:ads"
    2 = "shermdog/datadog-ecommerce-ecs:ads"
    3 = "shermdog/datadog-ecommerce-ecs:ads-fixed"
  }
}
