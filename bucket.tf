//
// Создать бакет в объектном хранилище (Object Storage)
//
resource "yandex_storage_bucket" "tg-bot-bucket" {
  bucket                = "tg-bot-bucket-${var.folder_id}"
  folder_id             = var.folder_id
  max_size              = 1073741824
  default_storage_class = "STANDARD"

  anonymous_access_flags {
    read        = true
    list        = false
    config_read = false
  }
}

//
// Загрузить в хранилище файл IMG.jpg для баннера
//
resource "yandex_storage_object" "tg-bot-banner" {
  bucket = "tg-bot-bucket-${var.folder_id}"
  key    = "IMG.jpg"
  source = "IMG.jpg"
}
