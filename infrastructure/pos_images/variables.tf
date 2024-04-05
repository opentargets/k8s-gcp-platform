variable "scope" {
  description = "Scope name for deploying resources"
  type        = string
}

variable "region" {
  description = "Region for deploying resources, default is 'europe-west1'"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Zone for deploying resources, default is 'europe-west1-d'"
  type        = string
  default     = "europe-west1-d"
}

variable "project" {
  description = "Project ID for deploying resources, default 'open-targets-eu-dev'"
  type        = string
  default     = "open-targets-eu-dev"
}

