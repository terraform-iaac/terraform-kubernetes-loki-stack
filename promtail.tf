# Config
resource "kubernetes_config_map" "promtail" {
  metadata {
    name      = "${var.promtail_name}-config"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace

    labels = {
      app = var.promtail_name
    }
  }

  data = {
    "promtail.yaml" = file("${path.module}/templates/promtail.yaml")
  }
}

# Deploy per node
module "promtail_daemonset" {
  source  = "terraform-iaac/daemonset/kubernetes"
  version = "1.2.4"


  image     = var.promtail_docker_image
  name      = var.promtail_name
  namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace

  args = ["-config.file=/etc/promtail/promtail.yaml", "-client.url=http://${module.loki_service.name}:3100/loki/api/v1/push"]

  service_account_name  = kubernetes_service_account.promtail.metadata[0].name
  service_account_token = true

  env_field = [
    {
      name       = "HOSTNAME"
      field_path = "spec.nodeName"
    }
  ]
  internal_port = var.promtail_internal_port

  security_context = [
    {
      read_only_root_filesystem = true
      run_as_group              = 0
      run_as_user               = 0
    }
  ]

  readiness_probe = [
    {
      failure_threshold     = 5
      initial_delay_seconds = 10
      period_seconds        = 10
      success_threshold     = 1
      timeout_seconds       = 1
      http_get = [
        {
          path = "/ready"
          port = "http-metrics"
        }
      ]
    }
  ]

  # Volumes
  volume_config_map = [
    {
      volume_name = "config"
      mode        = "0420"
      name        = kubernetes_config_map.promtail.metadata[0].name
    }
  ]
  volume_host_path = [
    {
      path_on_node = "/run/promtail"
      volume_name  = "run"
    },
    {
      path_on_node = "/var/lib/docker/containers"
      volume_name  = "docker"
    },
    {
      path_on_node = "/var/log/pods"
      volume_name  = "pods"
    }
  ]
  volume_mount = [
    {
      mount_path  = "/etc/promtail"
      volume_name = "config"
    },
    {
      mount_path  = "/run/promtail"
      volume_name = "run"
    },
    {
      mount_path  = "/var/lib/docker/containers"
      volume_name = "docker"
      read_only   = true
    },
    {
      mount_path  = "/var/log/pods"
      volume_name = "pods"
      read_only   = true
    }
  ]
}