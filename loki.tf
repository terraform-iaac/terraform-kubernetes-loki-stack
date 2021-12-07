# Service Account for loki
resource "kubernetes_service_account" "loki" {
  metadata {
    name      = "${var.loki_name}-sa"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace

    labels = {
      app = var.loki_name
    }

    annotations = var.loki_service_account_annotations
  }
}

# Generate config
data "template_file" "loki_config" {
  for_each = local.default

  template = local.default[var.provider_type].template
  vars     = local.default[var.provider_type].vars
}

# Add config to secret
resource "kubernetes_secret" "loki" {
  metadata {
    name      = "${var.loki_name}-config"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace

    labels = {
      app = var.loki_name
    }
  }

  data = {
    "loki.yaml" = data.template_file.loki_config[var.provider_type].rendered
  }
}

# Deploy loki as stateful-set
module "loki_stateful_set" {
  source  = "terraform-iaac/stateful-set/kubernetes"
  version = "1.3.1"

  image                            = var.loki_docker_image
  name                             = var.loki_name
  namespace                        = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  termination_grace_period_seconds = var.loki_termination_grace_period_seconds

  service_account_name = kubernetes_service_account.loki.metadata[0].name

  resources = var.loki_resources

  args = ["-config.file=/etc/loki/loki.yaml"]

  node_selector = var.loki_node_selector
  internal_port = var.loki_port

  security_context = [
    {
      fs_group                  = 10001
      run_as_group              = 10001
      run_as_user               = 10001
      run_as_non_root           = true
      read_only_root_filesystem = true
    }
  ]

  # Probes
  liveness_probe = [
    {
      http_get = [
        {
          path = "/ready"
          port = var.loki_port.0.name
        }
      ]
      initial_delay_seconds = 45
    }
  ]
  readiness_probe = [
    {
      http_get = [
        {
          path = "/ready"
          port = var.loki_port.0.name
        }
      ]
      initial_delay_seconds = 45
    }
  ]

  # Volumes
  volume_claim = var.provider_type == "local" ? [
    {
      name                   = "storage"
      namespace              = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
      access_modes           = var.pvc_access_modes != null ? var.pvc_access_modes : ["ReadWriteOnce"]
      requests_storage       = var.persistent_volume_size
      persistent_volume_name = var.persistent_volume_name
      storage_class_name     = var.pvc_storage_class_name != null ? var.pvc_storage_class_name : "default"
    }
  ] : []
  volume_empty_dir = var.provider_type == "local" ? [] : [
    {
      volume_name = "storage"
    }
  ]
  volume_secret = [
    {
      secret_name = kubernetes_secret.loki.metadata[0].name
      volume_name = "config"
    }
  ]
  volume_mount = [
    {
      mount_path  = "/etc/loki"
      volume_name = "config"
    },
    {
      mount_path  = "/data"
      volume_name = "storage"
      sub_path    = "loki-data"
    }
  ]
}

module "loki_service" {
  source  = "terraform-iaac/service/kubernetes"
  version = "1.0.3"

  app_name      = module.loki_stateful_set.name
  app_namespace = module.loki_stateful_set.namespace
  port_mapping  = var.loki_port
}