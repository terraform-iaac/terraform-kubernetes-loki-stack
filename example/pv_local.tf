resource "kubernetes_persistent_volume" "pv_loki" {
  metadata {
    name = "loki-pv"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    capacity = {
      storage = "4Gi"
    }
    storage_class_name               = "default"
    persistent_volume_reclaim_policy = "Retain"
    persistent_volume_source {
      # ...
    }
  }
}

# PV Local Loki Logging
module "pv_local_loki_stack" {
  source = "terraform-iaac/loki-stack/kubernetes"

  provider_type          = "local"
  pvc_storage_class_name = "default"
  pvc_access_modes       = ["ReadWriteOnce"]
  persistent_volume_name = kubernetes_persistent_volume.pv_loki.metadata.0.name
  persistent_volume_size = "4Gi"
}
