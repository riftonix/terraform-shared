variable "folder_uid" {
  description = "Grafana folder uid"
  type        = string
}

variable "global_jq_expression" {
  description = "Jq expression for dashboard modification"
  type        = string
  default     = null
}

variable "dashboards" {
  description = "Map of dashboard file paths to optional jq expressions for transformation"
  type        = map(string)
  default     = {}
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
