//
// Подтянуть переменные из файла
//
variable "token" { type = string }
variable "cloud_id" { type = string }
variable "folder_id" { type = string }
variable "zone" { type = string }
variable "bot_token" { type = string }

//
// Настройка провайдера
//
terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}
