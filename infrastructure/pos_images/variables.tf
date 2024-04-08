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
  description = "Folder location for the different contexts, e.g. dev, staging, production, default 'environments'"
  type        = string
  default = "environments"
}

variable "file_images_platform_ch" {
  description = "File name that contains the list of Clickhouse images to be deployed for Platform, default is 'images_platform_ch.txt'"
  type        = string
  default     = "images_platform_ch.txt"
}

variable "file_images_platform_os" {
  description = "File name that contains the list of OpenSearch images to be deployed for Platform, default is 'images_platform_os.txt'"
  type        = string
  default     = "images_platform_os.txt"
}

variable "file_images_ppp_ch" {
  description = "File name that contains the list of Clickhouse images to be deployed for PPP, default is 'images_ppp_ch.txt'"
  type        = string
  default     = "images_ppp_ch.txt"
}

variable "file_images_ppp_os" {
  description = "File name that contains the list of OpenSearch images to be deployed for PPP, default is 'images_ppp_os.txt'"
  type        = string
  default     = "images_ppp_os.txt"
}

variable "disk_size_platform_ch" {
  description = "Disk size for Clickhouse images for Platform, default is 64GiB"
  type        = number
  default     = 64
}

variable "disk_size_platform_os" {
  description = "Disk size for OpenSearch images for Platform, default is 128GiB"
  type        = number
  default     = 128
}

variable "disk_size_ppp_ch" {
  description = "Disk size for Clickhouse images for PPP, default is 64GiB"
  type        = number
  default     = 64
}

variable "disk_size_ppp_os" {
  description = "Disk size for OpenSearch images for PPP, default is 128GiB"
  type        = number
  default     = 128
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
