terraform {
    backend "gcs" {
      bucket = "open-targets-ops"
      prefix = "k8s-platform/pos_images"
    }
}