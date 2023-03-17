# Google Cloud Storage Loki Logging
# Create GCP Service Account for LOKI
resource "google_service_account" "loki" {
  account_id   = "loki"
  display_name = "Loki Logging"
  description  = "SA for Loki Logging with GCS Access"
}

# Assign permission to service account
resource "google_storage_bucket_access_control" "loki" {
  bucket = "gcs-bucket-loki-logs"
  role   = "WRITER"
  entity = "user-${google_service_account.loki.email}"
}
resource "google_storage_bucket_iam_member" "loki" {
  bucket = "gcs-bucket-loki-logs"
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.loki.email}"
}
resource "google_service_account_iam_binding" "loki_workload_identity" {
  service_account_id = google_service_account.loki.name

  role = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.gke_workload_identity_pool}[${module.gcs_loki_stack.namespace}/${module.gcs_loki_stack.loki_service_account_name}]",
  ]
}

module "gcs_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  # In case if Workload Identity is enabled.
  # Otherwise, your node must have RW permissions to GCS.
  loki_service_account_annotations = {
    "iam.gke.io/gcp-service-account" = google_service_account.loki.email
  }

  provider_type   = "gcp"
  gcs_bucket_name = "gcs-bucket-loki-logs"
}