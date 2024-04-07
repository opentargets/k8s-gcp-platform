locals {
  // Platform images for Clickhouse
  path_platform_images_file_ch = "${var.folder_context}/${var.file_images_platform_ch}"
  platform_images_raw_ch       = split("\n", file("${path.module}/${path_platform_images_file_ch}"))
  platform_images_idx_start_ch = length(local.platform_images_raw_ch) <= 3 ? 0 : length(local.platform_images_raw_ch) - 3
  // This is the effective listing of platform Clickhouse images to deploy
  platform_images_list_ch = slice(local.platform_images_raw_ch, local.platform_images_idx_start_ch, length(local.platform_images_raw_ch))
  platform_images_list_ch_with_zones = flatten([
    for zone in var.platform_zones : [
      for image in local.platform_images_list_ch : {
        image = image
        zone  = zone
      }
    ]
  ])
  // Platform images for OpenSearch
  path_platform_images_file_os = "${var.folder_context}/${var.file_images_platform_os}"
  platform_images_raw_os       = split("\n", file("${path.module}/${path_platform_images_file_os}"))
  platform_images_idx_start_os = length(local.platform_images_raw_os) <= 3 ? 0 : length(local.platform_images_raw_os) - 3
  // This is the effective listing of platform OpenSearch images to deploy
  platform_images_list_os = slice(local.platform_images_raw_os, local.platform_images_idx_start_os, length(local.platform_images_raw_os))
    platform_images_list_os_with_zones = flatten([
        for zone in var.platform_zones : [
        for image in local.platform_images_list_os : {
            image = image
            zone  = zone
        }
        ]
    ])

  // PPP images for Clickhouse
  path_ppp_images_file_ch = "${var.folder_context}/${var.file_images_ppp_ch}"
  ppp_images_raw_ch       = split("\n", file("${path.module}/${path_ppp_images_file_ch}"))
  ppp_images_idx_start_ch = length(local.ppp_images_raw_ch) <= 3 ? 0 : length(local.ppp_images_raw_ch) - 3
  // This is the effective listing of PPP Clickhouse images to deploy
  ppp_images_list_ch = slice(local.ppp_images_raw_ch, local.ppp_images_idx_start_ch, length(local.ppp_images_raw_ch))
    ppp_images_list_ch_with_zones = flatten([
        for zone in var.ppp_zones : [
        for image in local.ppp_images_list_ch : {
            image = image
            zone  = zone
        }
        ]
    ])
  // PPP images for OpenSearch
  path_ppp_images_file_os = "${var.folder_context}/${var.file_images_ppp_os}"
  ppp_images_raw_os       = split("\n", file("${path.module}/${path_ppp_images_file_os}"))
  ppp_images_idx_start_os = length(local.ppp_images_raw_os) <= 3 ? 0 : length(local.ppp_images_raw_os) - 3
  // This is the effective listing of PPP OpenSearch images to deploy
  ppp_images_list_os = slice(local.ppp_images_raw_os, local.ppp_images_idx_start_os, length(local.ppp_images_raw_os))
    ppp_images_list_os_with_zones = flatten([
        for zone in var.ppp_zones : [
        for image in local.ppp_images_list_os : {
            image = image
            zone  = zone
        }
        ]
    ])
}