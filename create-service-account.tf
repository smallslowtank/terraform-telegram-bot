//
// Создать сервисный аккаунт "sa-editor"
//
resource "yandex_iam_service_account" "sa-editor" {
  name      = "sa-editor"
  folder_id = var.folder_id
  description = "сервисный аккаунт для телеграм-бота"
}

//
// Выдать сервисному аккаунту "sa-editor" роль editor на каталог
//
resource "yandex_resourcemanager_folder_iam_binding" "sa-editor" {
  for_each = toset([
    "editor",
  ])
  role      = each.value
  folder_id = var.folder_id
  members = [
    "serviceAccount:${yandex_iam_service_account.sa-editor.id}",
  ]
  sleep_after = 5
}

//
// Создать статический ключ для сервисного аккаунта "sa-editor" (для работы с очередью)
//
resource "yandex_iam_service_account_static_access_key" "sa-editor-static-key" {
  service_account_id = yandex_iam_service_account.sa-editor.id
  description        = "static access key"
}