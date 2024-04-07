// Listing of deployed Platform Clickhouse disks with zones
output "platform_ch_disks" {
  value = [
    for idx in range(length(google_compute_disk.platform_ch_disk[*])) : {
        name = google_compute_disk.platform_ch_disk[idx].name
        zone = google_compute_disk.platform_ch_disk[idx].zone
    }
  ]
}

