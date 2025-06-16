//
// Создать функцию
//
resource "yandex_function" "tg-bot-function" {
  name               = "tg-bot-function"
  user_hash          = "v1"
  runtime            = "python312"
  entrypoint         = "index.handler"
  memory             = "128"
  execution_timeout  = "10"
  service_account_id = yandex_iam_service_account.sa-editor.id
  description        = "телеграм-бот"
  content {
    zip_filename = "tg-bot.zip"
  }
  environment = {
    "BOT_TOKEN" = var.bot_token
    "URL_IMG"   = "https://storage.yandexcloud.net/tg-bot-bucket-${var.folder_id}/${yandex_storage_object.tg-bot-banner.source}"
    "YDB_CS"    = "${yandex_ydb_database_serverless.tg-bot-ydb.ydb_full_endpoint}"
  }
}

//
// Создать триггер
//
resource "yandex_function_trigger" "tg-bot-trigger" {
  name        = "tg-bot-trigger"
  description = "триггер для телеграм-бота"
  folder_id   = var.folder_id
  message_queue {
    service_account_id = yandex_iam_service_account.sa-editor.id
    queue_id           = yandex_message_queue.tg-bot-message-queue.arn
    batch_cutoff       = 0
    batch_size         = 1
  }
  function {
    id                 = yandex_function.tg-bot-function.id
    tag                = "$latest"
    service_account_id = yandex_iam_service_account.sa-editor.id
  }
}
