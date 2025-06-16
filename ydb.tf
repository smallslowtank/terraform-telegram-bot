//
// Создать базу данных
//
resource "yandex_ydb_database_serverless" "tg-bot-ydb" {
  name                = "tg-bot-ydb"
  folder_id           = var.folder_id
  location_id         = "ru-central1"
  deletion_protection = false
  description = "база данных для телеграм-бота"
  sleep_after = 30
}

//
// Создать таблицу в базе
//
resource "yandex_ydb_table" "Quotes" {
  path              = "Quotes"
  connection_string = yandex_ydb_database_serverless.tg-bot-ydb.ydb_full_endpoint

  column {
    name     = "quote_id"
    type     = "Int64"
    not_null = true
  }
  column {
    name     = "quote"
    type     = "Utf8"
    not_null = true
  }
  column {
    name     = "author"
    type     = "Utf8"
    not_null = true
  }

  primary_key = ["quote_id"]

}
