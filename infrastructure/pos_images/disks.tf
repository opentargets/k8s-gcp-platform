// Platform Clickhouse disks
// Random resource to keep the disk name unique
resource "random_string" "disk_suffix_ch" {
    count = length(local.platform_images_list_ch_with_zones)

  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    image = local.platform_images_list_ch_with_zones[count.index].image
    zone  = local.platform_images_list_ch_with_zones[count.index].zone
  }
}
// Disk resource
resource "google_compute_disk" "platform_ch_disk" {
  count = length(local.platform_images_list_ch_with_zones)
  project = var.project

  name  = "${var.scope}-platform-ch-disk-${random_string.disk_suffix_ch[count.index].result}"
  type  = "pd-balanced"
  size  = var.disk_size_platform_ch
  zone  = local.platform_images_list_ch_with_zones[count.index].zone
  image = local.platform_images_list_ch_with_zones[count.index].image
}

// Platform Open Search disks
// Random resource to keep the disk name unique
resource "random_string" "disk_suffix_os" {
    count = length(local.platform_images_list_os_with_zones)

  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    image = local.platform_images_list_os_with_zones[count.index].image
    zone  = local.platform_images_list_os_with_zones[count.index].zone
  }
}
// Disk resource
resource "google_compute_disk" "platform_os_disk" {
  count = length(local.platform_images_list_os_with_zones)
  project = var.project

  name  = "${var.scope}-platform-os-disk-${random_string.disk_suffix_os[count.index].result}"
  type  = "pd-balanced"
  size  = var.disk_size_platform_os
  zone  = local.platform_images_list_os_with_zones[count.index].zone
  image = local.platform_images_list_os_with_zones[count.index].image
}

// PPP Clickhouse disks
// Random resource to keep the disk name unique
resource "random_string" "disk_suffix_ppp_ch" {
    count = length(local.ppp_images_list_ch_with_zones)

  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    image = local.ppp_images_list_ch_with_zones[count.index].image
    zone  = local.ppp_images_list_ch_with_zones[count.index].zone
  }
}
// Disk resource
resource "google_compute_disk" "ppp_ch_disk" {
  count = length(local.ppp_images_list_ch_with_zones)
  project = var.project

  name  = "${var.scope}-ppp-ch-disk-${random_string.disk_suffix_ppp_ch[count.index].result}"
  type  = "pd-balanced"
  size  = var.disk_size_ppp_ch
  zone  = local.ppp_images_list_ch_with_zones[count.index].zone
  image = local.ppp_images_list_ch_with_zones[count.index].image
}

// PPP Open Search disks
// Random resource to keep the disk name unique
resource "random_string" "disk_suffix_ppp_os" {
    count = length(local.ppp_images_list_os_with_zones)

  length  = 8
  lower   = true
  upper   = false
  special = false
  keepers = {
    image = local.ppp_images_list_os_with_zones[count.index].image
    zone  = local.ppp_images_list_os_with_zones[count.index].zone
  }
}
// Disk resource
resource "google_compute_disk" "ppp_os_disk" {
  count = length(local.ppp_images_list_os_with_zones)
  project = var.project

  name  = "${var.scope}-ppp-os-disk-${random_string.disk_suffix_ppp_os[count.index].result}"
  type  = "pd-balanced"
  size  = var.disk_size_ppp_os
  zone  = local.ppp_images_list_os_with_zones[count.index].zone
  image = local.ppp_images_list_os_with_zones[count.index].image
}
