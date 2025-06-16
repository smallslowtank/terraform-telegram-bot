//
// Создать лог-группу "default"
//
resource "yandex_logging_group" "default" {
  name      = "default"
  folder_id = var.folder_id
}