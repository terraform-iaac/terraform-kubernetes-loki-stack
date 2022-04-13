output "loki_service_name" {
  value = module.loki_service.name
}
output "loki_service_port" {
  value = var.loki_port.0.external_port
}
output "namespace" {
  value = var.namespace
}
output "loki_service_account_name" {
  value = kubernetes_service_account.loki.metadata[0].name
}