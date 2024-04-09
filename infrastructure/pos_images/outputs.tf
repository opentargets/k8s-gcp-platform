// Listing of deployed Platform Clickhouse disks with zones
output "platform_ch_disks" {
  value = [
    for idx in range(length(google_compute_disk.platform_ch_disk[*])) : {
        name = google_compute_disk.platform_ch_disk[idx].name
        image = google_compute_disk.platform_ch_disk[idx].image
        zone = google_compute_disk.platform_ch_disk[idx].zone
    }
  ]
}

// Listing of deployed Platform OpenSearch disks with zones
output "platform_os_disks" {
  value = [
    for idx in range(length(google_compute_disk.platform_os_disk[*])) : {
        name = google_compute_disk.platform_os_disk[idx].name
        image = google_compute_disk.platform_os_disk[idx].image
        zone = google_compute_disk.platform_os_disk[idx].zone
    }
  ]
}

// Listing of deployed PPP Clickhouse disks with zones
output "ppp_ch_disks" {
  value = [
    for idx in range(length(google_compute_disk.ppp_ch_disk[*])) : {
        name = google_compute_disk.ppp_ch_disk[idx].name
        image = google_compute_disk.ppp_ch_disk[idx].image
        zone = google_compute_disk.ppp_ch_disk[idx].zone
    }
  ]
}

// Listing of deployed PPP OpenSearch disks with zones
output "ppp_os_disks" {
  value = [
    for idx in range(length(google_compute_disk.ppp_os_disk[*])) : {
        name = google_compute_disk.ppp_os_disk[idx].name
        image = google_compute_disk.ppp_os_disk[idx].image
        zone = google_compute_disk.ppp_os_disk[idx].zone
    }
  ]
}

// Listing of the latest Platform clickhouse disks deployed, according to the most recent image
output "platform_ch_disks_most_recent" {
  value = [
    for idx in range(length(google_compute_disk.platform_ch_disk[*])) : {
        name = google_compute_disk.platform_ch_disk[idx].name
        image = google_compute_disk.platform_ch_disk[idx].image
        zone = google_compute_disk.platform_ch_disk[idx].zone
    }
    if google_compute_disk.platform_ch_disk[idx].image == local.platform_images_most_recent_ch
  ]
}

// Listing of the latest Platform OpenSearch disks deployed, according to the most recent image
output "platform_os_disks_most_recent" {
  value = [
    for idx in range(length(google_compute_disk.platform_os_disk[*])) : {
        name = google_compute_disk.platform_os_disk[idx].name
        image = google_compute_disk.platform_os_disk[idx].image
        zone = google_compute_disk.platform_os_disk[idx].zone
    }
    if google_compute_disk.platform_os_disk[idx].image == local.platform_images_most_recent_os
  ]
}

// Listing of the latest PPP Clickhouse disks deployed, according to the most recent image
output "ppp_ch_disks_most_recent" {
  value = [
    for idx in range(length(google_compute_disk.ppp_ch_disk[*])) : {
        name = google_compute_disk.ppp_ch_disk[idx].name
        image = google_compute_disk.ppp_ch_disk[idx].image
        zone = google_compute_disk.ppp_ch_disk[idx].zone
    }
    if google_compute_disk.ppp_ch_disk[idx].image == local.ppp_images_most_recent_ch
  ]
}