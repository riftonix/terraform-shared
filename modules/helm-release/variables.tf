variable "release_name" {
  description = "Release name for Helm chart"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to install the release into"
  type        = string
  default     = "default"
}

variable "chart" {
  description = "Name or path of the Helm chart to install"
  type        = string
}

variable "repository" {
  description = "Helm chart repository URL"
  type        = string
  default     = null
}

variable "chart_version" {
  description = "Specific chart version to install"
  type        = string
  default     = null
}

variable "create_namespace" {
  description = "Create namespace if it doesn't exist"
  type        = bool
  default     = false
}

variable "set" {
  description = "Custom values to be merged with the chart values"
  type = list(object({
    name  = string
    value = string
    type  = optional(string) // "auto" или "string"
  }))
  default = []
}

variable "values" {
  description = "Additional YAML values as a list of strings"
  type        = list(string)
  default     = []
}

variable "wait" {
  description = "Wait until all resources are ready before marking success"
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Time in seconds to wait for Kubernetes operations"
  type        = number
  default     = 300
}

variable "atomic" {
  description = "Delete the chart on failed install"
  type        = bool
  default     = false
}
