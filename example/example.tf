locals {
  node_spot_label_key     = "spot"
  node_multi_az_label_key = "multi_az"
}

# AWS s3 Loki Logging
module "aws_s3_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  loki_node_selector = {
    (local.node_spot_label_key)     = false
    (local.node_multi_az_label_key) = true
  }

  loki_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789:role/loki-logging"
  }

  provider_type = "aws"
  s3_name       = "loki-logs"
  s3_region     = "us-east-1"
}

# Google Cloud Storage Loki Logging
# Create GCP Service Account for LOKI
resource "google_service_account" "loki" {
  account_id   = "loki"
  display_name = "Loki logs bucket"
  description  = "SA for loki to access logs bucket"
}

# Assign permission to service account
resource "google_storage_bucket_access_control" "loki" {
  bucket = "loki-bucket-name"
  role   = "WRITER"
  entity = "user-${google_service_account.loki.email}"
}
resource "google_storage_bucket_iam_member" "loki" {
  bucket = "loki-bucket-name"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.loki.email}"
}
resource "google_service_account_iam_binding" "loki_workload_identity" {
  service_account_id = google_service_account.loki.name

  role = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${local.gke_workload_identity_pool}[${module.gcs_loki_stack.namespace}/${module.gcs_loki_stack.loki_service_account_name}]",
  ]
}
module "gcs_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  loki_service_account_annotations = {
    "iam.gke.io/gcp-service-account" = google_service_account.loki.email
  }

  loki_node_selector = {
    (local.node_spot_label_key)     = false
    (local.node_multi_az_label_key) = true
  }

  provider_type   = "gcp"
  gcs_bucket_name = "k8s-logging"
}

# Azure Loki Logging
module "azure_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  loki_node_selector = {
    (local.node_spot_label_key)     = false
    (local.node_multi_az_label_key) = true
  }

  provider_type              = "azure"
  storage_account_name       = "kuberneteslogging"
  storage_account_access_key = "super-secret-key"
  container_name             = "logs"
}

# Local Loki Logging
module "local_loki_stack" {
  source = "git::https://github.com/terraform-iaac/terraform-kubernetes-loki-stack.git"

  loki_node_selector = {
    (local.node_spot_label_key)     = false
    (local.node_multi_az_label_key) = true
  }

  provider_type          = "local"
  persistent_volume_name = kubernetes_persistent_volume.test.metadata.0.name
  persistent_volume_size = "4Gi" // We recommend to use a bit smaller value than Persistent Volume have (example: current_PV*0.9)
}
