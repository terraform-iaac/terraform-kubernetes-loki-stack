terraform {
  required_version = ">= 0.14.1"

  required_providers {
    kubernetes = ">= 2.0.1"
    helm       = ">= 2.1.0"
  }
}