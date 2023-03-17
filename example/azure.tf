module "azure_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  provider_type              = "azure"
  storage_account_name       = "kuberneteslogging"
  storage_account_access_key = "super-secret-key"
  container_name             = "logs"
}