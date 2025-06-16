### Создание телеграм-бота с помощью Terraform

Подразумевается, что все команды выполняются в Cloud Shell. Там уже установлены Git, Terraform и прочее.

Документаци по работе с Terraform https://yandex.cloud/ru/docs/tutorials/infrastructure-management/terraform-quickstart


#### Получить файлы проекта

Скачать репозиторий из GitHub. Т.к. дело происходит в Cloud Shell, то нужно делать через sudo:
```
sudo git clone https://github.com/smallslowtank/terraform-telegram-bot
```

Перейти в папку проекта
```
cd terraform-telegram-bot
```
Далее все команды выполняются в папке проекта

#### Первоначальная инициализация Terraform в Cloud Shell

Скопировать в домашнюю папку файл .terraformrc с настройками Terraform из папки проекта

```
cp .terraformrc ~
```

Т.к. дело происходит в Cloud Shell, то первый раз Terraform нужно инициализировать через sudo:
```
sudo terraform init
```


#### Базовые команды Terraform

Инициализация:
```
terraform init
```
Проверка конфигов:
```
terraform validate
```
Посмотреть план:
```
terraform plan
```
Посмотреть созданные ресурсы:
```
terraform state list
```

#### Задать переменные

Открыть в текстовом редакторе nano (или vim) файл terraform.tfvars и отредактировать значения переменных.

Для этого выполнить команду:
```
nano terraform.tfvars
```
**bot_token** Токен бота получается в телеграме у Ботфадера, документация https://core.telegram.org/bots/features#botfather

**token** OAuth-токен в сервисе Яндекс ID, для получения нужно перейти по ссылке и от туда его скопировать.

Ссылка https://oauth.yandex.ru/authorize?response_type=token&client_id=1a6990aa636648e9b2ef855fa7bec2fb

Документация https://yandex.cloud/ru/docs/iam/concepts/authorization/oauth-token

**cloud_id** Идентификатор облака, документация https://yandex.cloud/ru/docs/resource-manager/operations/cloud/get-id

**folder_id** Идентификатор каталога, документация https://yandex.cloud/ru/docs/resource-manager/operations/folder/get-id

**zone** При необходимости можно изменить зону на **a** или **b**, документация https://yandex.cloud/ru/docs/overview/concepts/geo-scope

```
bot_token = "токен_бота"
token     = "токен_авторизации"
cloud_id  = "идентификатор_облака"
folder_id = "идентификатор_каталога"
zone      = "ru-central1-d"
```
Сохранить изменения (Ctrl+O) и закрыть (Ctrl+X) редактор nano.

#### Создание ресурсов

Создать сервисный аккаунт и статический ключ:
```
terraform apply \
    -target=yandex_iam_service_account.sa-editor \
    -target=yandex_resourcemanager_folder_iam_binding.sa-editor \
    -target=yandex_iam_service_account_static_access_key.sa-editor-static-key
```
Создать объектное хранилище и базу данных::
```
terraform apply \
    -target=yandex_storage_bucket.tg-bot-bucket \
    -target=yandex_ydb_database_serverless.tg-bot-ydb
```
Создать таблицу в базе и загрузить файл баннера в хранилище:
```
terraform apply \
    -target=yandex_ydb_table.Quotes \
    -target=yandex_storage_object.tg-bot-banner
```
Создать остальные ресурсы:
```
terraform apply
```

#### Загрузить в таблицу данные

В Yandex Cloud Console (веб-интерфейс Яндекс Облака) зайти в базу данных, на вкладке "Навигация" нажать "Новый SQL-запрос", вставить текст запроса и нажать "Выполнить"
Документация https://yandex.cloud/ru/docs/ydb/operations/crud

Текст запроса:

```sql
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (1, 'Пока любишь — надеешься.', 'Элен Бронтэ');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (2, 'Цезарю многое непозволительно потому, что ему дозволено все.', 'Луций Анней Сенека');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (3, 'Если вы не можете увидеть себя богатым, то никогда не сможете этого добиться.', 'Роберт Кийосаки');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (4, 'Справедливость без мудрости значит много, мудрость без справедливости не значит ничего.', 'Марк Туллий Цицерон');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (5, 'Мир несовершенен, поскольку мы несовершенны.', 'Далай-лама XIV');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (6, 'Если не предъявлять к жизни особых претензий, то всё, что ни получаешь, будет прекрасным даром.', 'Эрих Мария Ремарк');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (7, 'Воистину, на свете есть и травы, не дающие цветов, и цветы, не дающие плодов!', 'Конфуций');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (8, 'Правильная постановка вопроса свидетельствует о некотором знакомстве с делом.', 'Фрэнсис Бэкон');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (9, 'Как много мы знаем и как мало мы понимаем.', 'Альберт Эйнштейн');
UPSERT INTO `Quotes` (`quote_id`, `quote`, `author`) VALUES (10, 'Никогда не спешите, и вы прибудете вовремя.', 'Шарль Морис де Талейран-Перигор');
```

#### Подключить вебхук

Команда выполняется в терминале (Cloud Shell)

```
curl \
  --request POST \
  --url https://api.telegram.org/bot<токен_бота>/setWebhook \
  --header 'content-type: application/json' \
  --data '{"url": "<домен_API-шлюза>/tg-bot"}'
```

#### Удаление ресурсов

Удалить из хранилища файд с баннером, удалить очередь и таблицу из базы:
```
terraform destroy -target=yandex_storage_object.tg-bot-banner -target=yandex_message_queue.tg-bot-message-queue -target=yandex_ydb_table.Quotes
```
Удалить остальные ресурсы:
```
terraform destroy
```

### Логгирование

Не стал отключать логгирование в функции и шлюзе. Вместо этого добавил создание лог-группы по умолчанию. Чтобы можно было её удалить через Terraform.

При необходимости логгирование можно отключить самостоятельно. Но есть нюанс - у шлюза сейчас не отключается логгирование через веб-интерфейс, возможно, это когда-нибудь починят. Через YC CLI отключаестя.

Функция. Логгирование отключается в "Редакторе" функции.

Шлюз https://yandex.cloud/ru/docs/api-gateway/operations/api-gw-logs-write