terraform {
  required_version = ">= 0.14.1"

  required_providers {
    kubernetes = ">= 1.11.0"
    helm       = ">= 2.1.0"
  }
}