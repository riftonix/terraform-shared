variable "manifest_content" {
  description = "Absolute path to yaml with k8s resources"
  type        = string
}

variable "sensitive_fields" {
  description = "List with sensitive keys"
  type        = list(string)
  default     = ["data"]
}

variable "force_new" {
  description = "Force to delete resource when yaml changed"
  type        = bool
  default     = false
}

variable "server_side_apply" {
  description = "Use server-side apply"
  type        = bool
  default     = false
}

variable "force_conflicts" {
  description = "Allow force conflicts"
  type        = bool
  default     = false
}

variable "apply_only" {
  description = "Only apply, not remove"
  type        = bool
  default     = false
}

variable "ignore_fields" {
  description = "List of fields to ignore"
  type        = list(string)
  default     = []
}

variable "override_namespace" {
  description = "Override the namespace to apply the kubernetes resource to, ignoring any declared namespace in the yaml_body"
  type        = string
  default     = null
}

variable "validate_schema" {
  description = "Setting to false will mimic kubectl apply --validate=false mode"
  type        = bool
  default     = true
}

variable "wait" {
  description = "Set this flag to wait or not for finalized to complete for deleted objects"
  type        = bool
  default     = false
}

variable "wait_for_rollout" {
  description = "Set this flag to wait or not for Deployments and APIService to complete rollout"
  type        = bool
  default     = true
}
