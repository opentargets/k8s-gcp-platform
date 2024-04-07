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

// Images configuration
variable "folder_context" {
  description = "Folder that defines the context for the images being deployed"
  type        = string
}

variable "file_images_platform" {
  description = "File name that contains the list of images to be deployed for Platform, default is 'images_platform.txt'"
  type        = string
  default     = "images_platform.txt"
}

variable "file_images_ppp" {
  description = "File name that contains the list of images to be deployed for PPP, default is 'images_ppp.txt'"
  type        = string
  default     = "images_ppp.txt"
}

variable "platform_zones" {
  description = "Zones for deploying platform images, default is ['europe-west1-b', 'europe-west1-c', 'europe-west1-d']"
  type        = list(string)
  default     = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
}

variable "ppp_zones" {
  description = "Zones for deploying ppp images, default is ['europe-west1-b', 'europe-west1-c', 'europe-west1-d']"
  type        = list(string)
  default     = ["europe-west1-b", "europe-west1-c", "europe-west1-d"]
  
}