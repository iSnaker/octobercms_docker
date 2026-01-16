# October CMS Docker

Docker-образ для October CMS 1.1.12 на базе PHP 7.4 и Apache.

## 📋 Описание

Этот проект предоставляет готовый Docker-образ для быстрого развертывания October CMS версии 1.1.12. Образ включает все
необходимые зависимости, настроенный PHP, Apache и вспомогательные инструменты для работы с October CMS.

## 🚀 Возможности

- **October CMS 1.1.12** - полная установка CMS
- **PHP 7.4** с предустановленными расширениями:
    - `exif`, `gd`, `mysqli`, `opcache`, `pdo_pgsql`, `pdo_mysql`, `zip`
- **Apache** с включенным `mod_rewrite`
- **Node.js 20.x** с npm для работы с frontend-инструментами
- **Composer** для управления зависимостями
- **Cron** для автоматического выполнения задач
- **Вспомогательные команды** (`artisan`, `tinker`, `october`)
- **Настраиваемая конфигурация** через переменные окружения

## 📦 Требования

- Docker
- Docker Compose (опционально, для работы с базами данных)

## 🛠️ Установка и запуск

### Базовая установка

1. Клонируйте репозиторий:

```bash
git clone <repository-url>
cd snapix-dockered/october
```

2. Соберите Docker-образ:

```bash
docker build -t october-cms:1.1.12 .
```

3. Запустите контейнер:

```bash
docker run -d \
  --name october-cms \
  -p 8080:80 \
  -v $(pwd)/storage:/var/www/html/storage \
  -v $(pwd)/plugins:/var/www/html/plugins \
  -v $(pwd)/themes:/var/www/html/themes \
  october-cms:1.1.12
```

4. Откройте браузер по адресу: http://localhost:8080

### Проверка установки

После запуска контейнера проверьте версии установленного ПО:

```bash
# Проверка версии PHP
docker exec october-cms php --version

# Проверка версии Node.js (должна быть 20.x)
docker exec october-cms node --version

# Проверка версии npm
docker exec october-cms npm --version

# Проверка версии Composer
docker exec october-cms composer --version
```

### Использование с Docker Compose

Пример файла `docker-compose.yml` с поддержкой виртуальных хостов, MySQL и phpMyAdmin:

```yaml
#docker-compose.yml
services:
  nginx-proxy:
    image: nginxproxy/nginx-proxy
    ports:
      - "80:80"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
    networks:
      - october-network

  october:
    image: snapix/october:latest
    expose:
      - 80
    ports:
      - 8888:80
      - 4001:3000  # для BrowserSync - опционально
    depends_on:
      mysql:
        condition: service_healthy
    volumes:
      - config:/var/www/html/config
      - plugins:/var/www/html/plugins
      - ./theme:/var/www/html/themes/theme # пример пользовательской темы
      - ./plugin:/var/www/html/plugins/yourplugin # пример пользовательского плагина
      - ./storage:/var/www/html/storage
    environment:
      - DB_TYPE=mysql
      - DB_HOST=mysql
      - DB_DATABASE=octobercms
      - DB_USERNAME=root
      - DB_PASSWORD=root
      - APP_ENV=docker
      - TZ=UTC
      - # плагины для автоматической установки при старте контейнера, через запятую
      - OCTOBER_PLUGINS=rainlab.builder,rainlab.user,blakejones.magicforms,rainlab.blog,rainlab.pages,ToughDeveloper.ImageResizer,Zen.Robots,offline.sitesearch,RainLab.Translate
      # Опционально: Виртуальные хосты для nginx-proxy. Можно указать несколько через запятую.
      - VIRTUAL_HOST=site1.local,site2.local
    networks:
      - october-network

  mysql:
    image: mysql:5.7
    platform: linux/amd64
    ports:
      - 3306:3306
    volumes:
      - mysql-data:/var/lib/mysql
    environment:
      - MYSQL_ROOT_PASSWORD=root
      - MYSQL_DATABASE=octobercms
    healthcheck:
      test: [ "CMD", "mysqladmin", "ping", "-h", "localhost", "-proot" ]
      interval: 5s
      timeout: 3s
      retries: 10
    networks:
      - october-network

  phpmyadmin:
    image: phpmyadmin
    restart: always
    depends_on:
      - mysql
    ports:
      - 8080:80
    environment:
      - PMA_HOST=mysql
      - PMA_USER=root
      - PMA_PASSWORD=root
      - UPLOAD_LIMIT=300M
      - MAX_EXECUTION_TIME=600
      - MEMORY_LIMIT=512M
    networks:
      - october-network

volumes:
  mysql-data:
  config:
  plugins:

networks:
  october-network:
    driver: bridge
```

Запустите:

```bash
docker-compose up -d
```

Доступ к сервисам:

- **October CMS**: http://localhost:8888
- **phpMyAdmin**: http://localhost:8080
- **MySQL**: localhost:3306

## ⚙️ Переменные окружения

### Настройки базы данных

| Переменная       | Описание                               | Значение по умолчанию     |
|------------------|----------------------------------------|---------------------------|
| `DB_TYPE`        | Тип базы данных (sqlite, mysql, pgsql) | `sqlite`                  |
| `DB_HOST`        | Хост базы данных                       | `mysql`                   |
| `DB_PORT`        | Порт базы данных                       | -                         |
| `DB_DATABASE`    | Имя базы данных                        | -                         |
| `DB_USERNAME`    | Имя пользователя БД                    | -                         |
| `DB_PASSWORD`    | Пароль БД                              | -                         |
| `DB_PATH_SQLITE` | Путь к SQLite файлу                    | `storage/database.sqlite` |

### Настройки October CMS

| Переменная        | Описание                                                     | Значение по умолчанию |
|-------------------|--------------------------------------------------------------|-----------------------|
| `OCTOBER_PLUGINS` | Список плагинов для автоматической установки (через запятую) | -                     |
| `APP_URL`         | URL приложения                                               | `http://localhost`    |
| `APP_ENV`         | Окружение (local, production, docker)                        | `production`          |
| `TZ`              | Часовой пояс                                                 | `UTC`                 |

### Настройки PHP

| Переменная                | Описание                               | Значение по умолчанию |
|---------------------------|----------------------------------------|-----------------------|
| `PHP_DISPLAY_ERRORS`      | Отображение ошибок PHP                 | `off`                 |
| `PHP_MEMORY_LIMIT`        | Лимит памяти PHP                       | `128M`                |
| `PHP_UPLOAD_MAX_FILESIZE` | Максимальный размер загружаемого файла | `32M`                 |
| `PHP_POST_MAX_SIZE`       | Максимальный размер POST запроса       | `32M`                 |

### Настройки Xdebug (для разработки)

| Переменная           | Описание                     |
|----------------------|------------------------------|
| `XDEBUG_ENABLE`      | Включить Xdebug (true/false) |
| `XDEBUG_REMOTE_HOST` | Хост для удаленной отладки   |

## 🔧 Вспомогательные команды

Внутри контейнера доступны следующие команды:

```bash
# Выполнение Artisan команд
docker exec -it october-cms artisan cache:clear

# Запуск Tinker (интерактивная консоль)
docker exec -it october-cms tinker

# Команды October CMS
docker exec -it october-cms october up        # Обновление плагинов и миграций
docker exec -it october-cms october migrate   # Выполнение миграций
```

## 📁 Структура проекта

```
.
├── Dockerfile                  # Основной Dockerfile
├── docker-oc-entrypoint       # Скрипт инициализации контейнера
├── config/
│   └── docker/                # Конфигурационные файлы October CMS
│       ├── app.php
│       ├── cache.php
│       ├── cms.php
│       ├── database.php
│       ├── environment.php
│       ├── mail.php
│       ├── queue.php
│       ├── session.php
│       └── system.php
└── README.md
```

## 🔐 Права доступа

Docker-образ автоматически настраивает права доступа для следующих директорий:

- `/var/www/html/storage` - 775
- `/var/www/html/plugins` - 775
- `/var/www/html/themes` - 775

Владелец: `www-data:www-data`

## 📦 Node.js и npm

Образ включает Node.js версии 20.x и npm для работы с frontend-инструментами.

Проверка версий:

```bash
docker exec -it october-cms node --version
docker exec -it october-cms npm --version
```

Установка зависимостей:

```bash
docker exec -it october-cms npm install
```

Запуск скриптов:

```bash
docker exec -it october-cms npm run build
```

## 🕐 Cron задачи

Контейнер автоматически запускает планировщик задач October CMS каждую минуту:

```bash
* * * * * php artisan schedule:run
```

## 🐛 Отладка

Для просмотра логов контейнера:

```bash
docker logs -f october-cms
```

Для входа в контейнер:

```bash
docker exec -it october-cms bash
```

Логи October CMS находятся в:

```bash
/var/www/html/storage/logs/
```

## 📝 Примечания

Образ создан исключительно для поддержки старых проектов на October CMS 1.1.12. Для других версий рекомендуется использовать
официальные образы или создавать собственные на их основе.

- При первом запуске с MySQL/PostgreSQL убедитесь, что база данных создана
- SQLite используется по умолчанию для быстрого старта
- Для production рекомендуется использовать MySQL или PostgreSQL
- Все пользовательские данные (плагины, темы, хранилище) должны быть смонтированы как volumes

## 📄 Лицензия

October CMS распространяется под [MIT License](https://github.com/octobercms/october/blob/master/LICENSE).

## 🔗 Полезные ссылки

- [Официальная документация October CMS](https://octobercms.com/docs)
- [GitHub репозиторий October CMS](https://github.com/octobercms/october)
- [Документация Docker](https://docs.docker.com/)

