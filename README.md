# Kubernetes logging by Loki stack (Loki+Promtail)

Terraform module for deploy Loki logging to your kubernetes cluster, with multi cloud storage support.

## Wokrflow

Module creates all necessary resources for logging important containers inside your kubernetes cluster. Previously you need to have Grafana to see your logs. Loki is only separate Data Source for Grafana.
Module supports different storages for logs: AWS S3 bucket, GCP GCS Bucket, Azure Blob storage and Kubernetes Persistent Volume.

## Software Requirements

Name | Description
--- | --- |
Terraform | >= v0.14.9
Helm provider | >= 2.1.0
Kubernetes provider | >= v2.0.1

## Usage
#### AWS with S3 as storage
```
module "aws_s3_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  # In case if IRSA is enabled. IRSA must have S3 RW Policy access.
  # Otherwise, your instance must have S3 RW Policy attached.
  loki_service_account_annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::123456789:role/loki-logging"
  }

  provider_type = "aws"
  s3_name       = "s3-bucket-loki-logs"
  s3_region     = "us-east-1"
}
```
####  GCP with GCS as storage
```
module "gcs_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"
  
  # In case if Workload Identity is enabled.
  # Otherwise, your node must have RW permissions to GCS.
  loki_service_account_annotations = {
    "iam.gke.io/gcp-service-account" = "loki-sa@projectid.iam.gserviceaccount.com"
  }

  provider_type   = "gcp"
  gcs_bucket_name = "gcs-bucket-loki-logs"
}
```
#### Azure with Blob as storage
```
module "azure_loki_stack" {
  source  = "terraform-iaac/loki-stack/kubernetes"

  provider_type              = "azure"
  storage_account_name       = "kuberneteslogging"
  storage_account_access_key = "super-secret-key"
  container_name             = "logs"
}
```

#### PV local as storage
```
module "pv_local_loki_stack" {
  source = "terraform-iaac/loki-stack/kubernetes"

  provider_type          = "local"
  pvc_storage_class_name = "default"
  pvc_access_modes       = ["ReadWriteOnce"]
  persistent_volume_name = kubernetes_persistent_volume.pv_loki.metadata.0.name
  persistent_volume_size = "4Gi"
}
```
### Note: ***provider_type*** supports only ***aws, azure, gcp or local*** value. Every value require own variables (see ***locals*** section in varaibles.tf file or check examples.)

## Inputs

Name | Description | Type     | Default                                                                       | Example | Required
--- | --- |----------|-------------------------------------------------------------------------------|--- |--- 
namespace | Name of namespace where you want to deploy loki-stack | `string` | `monitoring`                                                                  | n/a | no
create_namespace | Create namespace by module? true or false | `bool` | true                                                                          | n/a | no
loki_resources | Compute Resources required by loki container. CPU/RAM requests | `map` | <pre>{<br>   request_cpu    = "50m"<br>   request_memory = "100Mi"<br>}</pre> | <pre>{<br>   request_cpu    = "20m"<br>   request_memory = "50Mi"<br>}</pre> | no
promtail_resources | Compute Resources required by promtail container. CPU/RAM requests | `map` | <pre>{<br>   request_cpu    = "20m"<br>   request_memory = "50Mi"<br>}</pre>  | <pre>{<br>   request_cpu    = "20m"<br>   request_memory = "50Mi"<br>}</pre> | no

### Loki variables
Name | Description                                                                                                                 | Type | Default                                                                                                                        | Example | Required
--- |-----------------------------------------------------------------------------------------------------------------------------| --- |--------------------------------------------------------------------------------------------------------------------------------|--- |--- 
loki_name | Loki application name                                                                                                       | `string` | `loki`                                                                                                                         | n/a | no
loki_docker_image | Image for Loki container                                                                                                    | `string` | `grafana/loki:2.3.0`                                                                                                           | n/a | no
loki_termination_grace_period_seconds | Grace period applies to the total time it takes for both the PreStop hook to execute and for the Container to stop normally | `integer` | `4800`                                                                                                                         | n/a | no
loki_port | Port mapping to kubernetes service                                                                                          | <pre>list(object({<br>    name          = string<br>    internal_port = integer<br>    external_port = integer<br>}))</pre> | <pre>\[<br>  {<br>    name          = "http-metrics"<br>    internal_port = 3100<br>    external_port = 3100<br>  }<br>]</pre> | n/a | no 
loki_node_selector | Select node to deploy loki stack                                                                                            | `map` | `null`                                                                                                                         | <pre>{<br>    (local.node_spot_label_key)     = false<br>    (local.node_multi_az_label_key) = true<br>}</pre> | no
loki_toleration | Loki Pod node tolerations                                                                                                   | <pre>list(object({<br>    effect             = string // (Optional)<br>    key                = string // (Optional)<br>    operator           = string // (Optional)<br>    toleration_seconds = number // (Optional)<br>    value              = string // (Optional)<br>  }))</pre>   | `[]` | <pre>[<br>  {<br>    effect             = "NoSchedule"<br>    key                = "gpu"<br>    operator           = "Equal"<br>    value              = "true"<br>  }<br>]</pre>    | no |
loki_service_account_annotations | Add additional account annotations to Loki service account                                                                  | `map` | `ReadWriteMany`                                                                                                                | n/a | no

### Promtail
Name | Description                   | Type | Default | Example | Required
--- |-------------------------------| --- | --- |--- |--- 
promtail_name | Promtail application name     | `string` | `monitoring-alertmanager-pv` | n/a | no
promtail_docker_image | Image for Promtail container  | `string` | `2Gi` | n/a | no
promtail_internal_port | Port mapping to daemon-set    | <pre>list(object({<br>    name          = string<br>    internal_port = integer<br>}))</pre> | <pre>\[<br>  {<br>    name          = "http-metrics"<br>    internal_port = 3100<br>  }<br>]</pre> | n/a | no
promtail_toleration | Promtail pod node tolerations | <pre>list(object({<br>    effect             = string // (Optional)<br>    key                = string // (Optional)<br>    operator           = string // (Optional)<br>    toleration_seconds = number // (Optional)<br>    value              = string // (Optional)<br>  }))</pre>   | `[]` | <pre>[<br>  {<br>    effect             = "NoSchedule"<br>    key                = "gpu"<br>    operator           = "Equal"<br>    value              = "true"<br>  }<br>]</pre>    | no |

### Storage variables
Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
provider_type | Choose what type of provider you want (aws, azure, gcp and local) | `string` | n/a | `azure` | yes

### ***AWS S3***
Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
s3_region | AWS region where s3 locate | `string` | `null` | `us-east-1` | no
s3_name | Name of s3 bucket | `string` | `null` | `s3-bucket-logs` | no
### ***GCP storage***
Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
gcs_bucket_name | Google Cloud Storage bucket name | `string` | `null` | `gcs-storage-logs` | no
### ***Azure Blob Storage***
Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
storage_account_name | The Microsoft Azure storage account name to be used | `string` | `null` | `aks-application-logs` | no
storage_account_access_key | The Microsoft Azure storage account access key to use | `string` | `null` | `sEcRetKeY` | no
container_name | Name of the blob container used to store chunks. This container must be created before running cortex. | `string` | `null` | `my-app-logs` | no
### ***Local***
Name | Description | Type | Default | Example | Required
--- | --- | --- | --- |--- |--- 
persistent_volume_name | Name of persistant volume | `string` | `null` | `k8s-my-app-logs-pv` | no
persistent_volume_size | Name of persistant disk size | `string` | `null` | `4Gi` | no
pvc_access_modes | Mode for access to data | `string` | `null` | `["ReadWriteOnce"]` | no
pvc_storage_class_name | Type of storage class name | `string` | `null` | `default` | no
