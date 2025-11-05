variable "folder_uid" {
  description = "Grafana folder uid"
  type        = string
}

variable "dashboards" {
  description = "Dashboards list to create"
  type = list(object({
    title         = optional(string)
    uid           = optional(string)
    body          = string
  }))
}

variable "org_id" {
  description = "Grafana org ID"
  type        = string
  default     = null
}

variable "overwrite" {
  description = "Overwrite grafana dashboard"
  type        = bool
  default     = true
}
