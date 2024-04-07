locals {
  // Platform images for Clickhouse
  path_platform_images_file_ch = "${var.folder_context}/${var.file_images_platform_ch}"
  platform_images_raw_ch       = split("\n", file("${path.module}/${path_platform_images_file_ch}"))
  platform_images_idx_start_ch = len(local.platform_images_raw_ch) <= 3 ? 0 : len(local.platform_images_raw_ch) - 3
  // This is the effective listing of platform Clickhouse images to deploy
  platform_images_list_ch = slice(local.platform_images_raw_ch, local.platform_images_idx_start_ch, len(local.platform_images_raw_ch))
  // Platform images for OpenSearch
  path_platform_images_file_os = "${var.folder_context}/${var.file_images_platform_os}"
  platform_images_raw_os       = split("\n", file("${path.module}/${path_platform_images_file_os}"))
  platform_images_idx_start_os = len(local.platform_images_raw_os) <= 3 ? 0 : len(local.platform_images_raw_os) - 3
  // This is the effective listing of platform OpenSearch images to deploy
  platform_images_list_os = slice(local.platform_images_raw_os, local.platform_images_idx_start_os, len(local.platform_images_raw_os))

  // PPP images
  path_ppp_images_file = "${var.folder_context}/${var.file_images_ppp}"
  ppp_images_raw       = split("\n", file("${path.module}/${path_ppp_images_file}"))
  ppp_images_idx_start = len(local.ppp_images_raw) <= 3 ? 0 : len(local.ppp_images_raw) - 3
  // This is the effective listing of ppp images to deploy
  ppp_images_list = slice(local.ppp_images_raw, local.ppp_images_idx_start, len(local.ppp_images_raw))
}