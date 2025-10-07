variable "folder_uid" {
  description = "Grafana folder uid"
  type        = string
}

variable "dashboards" {
  description = "Список дашбордов для создания. Каждый должен содержать title, uid и body"
  type = list(object({
    title         = optional(string)
    uid           = optional(string)
    body          = any
  }))
}

variable "org_id" {
  description = "ID организации Grafana"
  type        = string
  default     = null
}

variable "overwrite" {
  description = "ID организации Grafana"
  type        = bool
  default     = true
}
