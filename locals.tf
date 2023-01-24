locals {
  default = {
    aws = {
      template = "${path.module}/templates/aws_loki.yaml"
      vars = {
        S3_REGION = var.s3_region
        S3_NAME   = var.s3_name
      }
    },
    azure = {
      template = "${path.module}/templates/azure_loki.yaml"
      vars = {
        ACCOUNT_KEY    = var.storage_account_access_key
        ACCOUNT_NAME   = var.storage_account_name
        CONTAINER_NAME = var.container_name
      }
    },
    gcp = {
      template = "${path.module}/templates/gcp_loki.yaml"
      vars = {
        GCS_BUCKET_NAME = var.gcs_bucket_name
      }
    },
    local = {
      template = "${path.module}/templates/local_loki.yaml"
      vars = {
        LOCAL_STORAGE_PATH = "/data/loki/chunks"
        RETENTION_PERIOD   = var.local_storage_retention_period
      }
    }
  }
}