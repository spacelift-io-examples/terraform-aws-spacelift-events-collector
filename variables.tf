variable "api_gw_enabled" {
  default     = false
  description = "Install api gateway in commercial"
  type        = bool
}

variable "buffer_interval" {
  default     = 300
  description = "Buffer incoming data for the specified period of time, in seconds, before delivering it to the destination"
  type        = number
}

variable "buffer_size" {
  default     = 5
  description = "Buffer incoming events to the specified size, in MBs, before delivering it to the destination"
  type        = number
}

variable "delete_events_when_destroying_stack" {
  default     = false
  description = "Whether to delete stored events when destroying the stack"
  type        = bool
}

variable "events_expiration_days" {
  default     = 365
  description = "Keep the events for this number of days"
  type        = number
}

variable "logs_retention_days" {
  default     = 14
  description = "Keep the logs for this number of days"
  type        = number
}

variable "logs_verbose" {
  default     = false
  description = "Include debug information in the logs"
  type        = bool
}

variable "python_version" {
  default     = "3.9"
  description = "AWS Lambda Python runtime version"
  type        = string
}

variable "secret" {
  default     = ""
  description = "Secret to be expected by the collector"
  sensitive   = true
  type        = string
}
