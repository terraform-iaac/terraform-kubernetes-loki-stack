locals {
  default = {
    aws = {
      template = file("${path.module}/templates/aws_loki.yaml")
      vars = {
        S3_REGION = var.s3_region
        S3_NAME   = var.s3_name
      }
    },
    azure = {
      template = file("${path.module}/templates/azure_loki.yaml")
      vars = {
        ACCOUNT_KEY    = var.storage_account_access_key
        ACCOUNT_NAME   = var.storage_account_name
        CONTAINER_NAME = var.container_name
      }
    },
    gcp = {
      template = file("${path.module}/templates/gcp_loki.yaml")
      vars = {
        GCS_BUCKET_NAME = var.gcs_bucket_name
      }
    },
    local = {
      template = file("${path.module}/templates/local_loki.yaml")
      vars = {
        LOCAL_STORAGE_PATH = "/data/loki/chunks"
      }
    }
  }
}

# Namespace
variable "namespace" {
  description = "Namespace name"
  type        = string
  default     = "loki-test"
}
variable "create_namespace" {
  description = "Create namespace by module ? true or false"
  type        = bool
  default     = true
}

# Loki
variable "loki_name" {
  default = "loki"
}
variable "loki_docker_image" {
  default = "grafana/loki:2.3.0"
}
variable "loki_termination_grace_period_seconds" {
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
variable "loki_service_account_annotations" {
  default = {}
}

# Promtail
variable "promtail_name" {
  default = "promtail"
}
variable "promtail_docker_image" {
  default = "grafana/promtail:2.3.0"
}

variable "promtail_internal_port" {
  default = [
    {
      name          = "http-metrics"
      internal_port = "3101"
    }
  ]
}


variable "provider_type" {
  description = "Choose what type of provider you want (aws, azure, gcp and local)" // SUPPORTS ONLY: aws, azure, gcp and local
  type        = string
}
# Storage variables
## AWS
variable "s3_region" {
  description = "AWS region where s3 locate"
  default     = null
}
variable "s3_name" {
  description = "Name of s3 bucket"
  default     = null
}
## GCP
variable "gcs_bucket_name" {
  description = "Google Cloud Storage bucket name"
  default     = null
}
## Azure
variable "storage_account_name" {
  description = "The Microsoft Azure storage account name to be used"
  default     = null
}
variable "storage_account_access_key" {
  description = "The Microsoft Azure storage account access key to use"
  default     = null
}
variable "container_name" {
  description = "Name of the blob container used to store chunks. This container must be created before running cortex."
  default     = null
}
## Local storage
variable "persistent_volume_name" {
  description = "Name of persistant volume"
  default     = null
}
variable "persistent_volume_size" {
  description = "Name of persistant disk size"
  default     = null
}
variable "pvc_access_modes" {
  description = "Mode for access to data"
  default     = null
}
variable "pvc_storage_class_name" {
  description = "Type of storage class name"
  default     = null
}