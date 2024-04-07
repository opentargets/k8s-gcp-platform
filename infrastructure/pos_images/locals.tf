locals {
  // Platform images
  path_platform_images_file = "${var.folder_context}/${var.file_images_platform}"
  platform_images_raw       = split("\n", file("${path.module}/${path_platform_images_file}"))
  platform_images_idx_start = len(local.platform_images_raw) <= 3 ? 0 : len(local.platform_images_raw) - 3
  // This is the effective listing of platform images to deploy
  platform_images_list      = slice(local.platform_images_raw, local.platform_images_idx_start, len(local.platform_images_raw))
}