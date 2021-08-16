resource "kubernetes_service_account" "promtail" {
  metadata {
    name      = "${var.promtail_name}-sa"
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace

    labels = {
      app = var.promtail_name
    }
  }
}

resource "kubernetes_cluster_role" "promtail" {
  metadata {
    name = "${var.promtail_name}-cluster-role"

    labels = {
      app = var.promtail_name
    }
  }

  rule {
    api_groups = [""]
    resources = [
      "nodes",
      "nodes/proxy",
      "services",
      "endpoints",
      "pods"
    ]
    verbs = [
      "get",
      "watch",
      "list"
    ]
  }
}

resource "kubernetes_cluster_role_binding" "promtail" {
  metadata {
    name = "${var.promtail_name}-cluster-role-binding"

    labels = {
      app = var.promtail_name
    }
  }
  role_ref {
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role.promtail.metadata[0].name
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.promtail.metadata[0].name
    namespace = var.create_namespace ? kubernetes_namespace.namespace[0].id : var.namespace
  }
}