variable "dd_api_key" {
  type        = string
  description = "Datadog Agent API key"
}

variable "rick_ip" {
  type        = string
  description = "Rick's IP"
}

variable "key_pair" {
  type        = string
  description = "Key pair for EC2 access"
  default     = "rick.sherman"
}
