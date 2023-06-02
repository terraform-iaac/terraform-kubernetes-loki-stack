# Resources for services
variable "loki_resources" {
  description = "(Optional) Compute Resources required by loki container. CPU/RAM requests"
  type = object(
    {
      request_cpu    = optional(string)
      request_memory = optional(string)
      limit_cpu      = optional(string)
      limit_memory   = optional(string)
    }
  )
  default = {
    request_cpu    = "50m"
    request_memory = "100Mi"
  }
}
variable "promtail_resources" {
  description = "(Optional) Compute Resources required by promtail container. CPU/RAM requests"
  type = object(
    {
      request_cpu    = optional(string)
      request_memory = optional(string)
      limit_cpu      = optional(string)
      limit_memory   = optional(string)
    }
  )
  default = {
    request_cpu    = "20m"
    request_memory = "50Mi"
  }
}

# Namespace
variable "namespace" {
  description = "Namespace name"
  type        = string
  default     = "loki-stack"
}
variable "create_namespace" {
  description = "Create namespace by module ? true or false"
  type        = bool
  default     = true
}

# Loki
variable "loki_name" {
  type    = string
  default = "loki"
}
variable "loki_docker_image" {
  type    = string
  default = "grafana/loki:2.7.4"
}
variable "loki_termination_grace_period_seconds" {
  type    = number
  default = 4800
}
variable "loki_port" {
  default = [
    {
      name          = "http-metrics"
      internal_port = 3100
      external_port = 3100
    }
  ]
}
variable "loki_node_selector" {
  default = null
}
variable "loki_toleration" {
  default = []
}
variable "loki_service_account_annotations" {
  default = {}
}

# Promtail
variable "promtail_name" {
  type    = string
  default = "promtail"
}
variable "promtail_docker_image" {
  type    = string
  default = "grafana/promtail:2.7.4"
}

variable "promtail_internal_port" {
  default = [
    {
      name          = "http-metrics"
      internal_port = "3101"
    }
  ]
}

variable "promtail_toleration" {
  default = []
}


variable "provider_type" {
  description = "Choose what type of provider you want (aws, azure, gcp and local)" // SUPPORTS ONLY: aws, azure, gcp and local
  type        = string
}
# Storage variables
## AWS
variable "s3_region" {
  type        = string
  description = "AWS region where s3 locate"
  default     = null
}
variable "s3_name" {
  type        = string
  description = "Name of s3 bucket"
  default     = null
}
## GCP
variable "gcs_bucket_name" {
  type        = string
  description = "Google Cloud Storage bucket name"
  default     = null
}
## Azure
variable "storage_account_name" {
  type        = string
  description = "The Microsoft Azure storage account name to be used"
  default     = null
}
variable "storage_account_access_key" {
  type        = string
  description = "The Microsoft Azure storage account access key to use"
  default     = null
}
variable "container_name" {
  type        = string
  description = "Name of the blob container used to store chunks. This container must be created before running cortex."
  default     = null
}
## Local storage
variable "persistent_volume_name" {
  type        = string
  description = "Name of persistant volume"
  default     = null
}
variable "persistent_volume_size" {
  type        = string
  description = "Name of persistant disk size"
  default     = null
}
variable "pvc_access_modes" {
  type        = list(string)
  description = "Mode for access to data"
  default     = null
}
variable "pvc_storage_class_name" {
  type        = string
  description = "Type of storage class name"
  default     = null
}
variable "local_storage_retention_period" {
  type        = string
  description = "How far back tables will be kept before they are deleted. 0s disables deletion"
  default     = "336h"
}