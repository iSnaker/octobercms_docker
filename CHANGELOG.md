# Changelog

Все значимые изменения в проекте будут документированы в этом файле.

Формат основан на [Keep a Changelog](https://keepachangelog.com/ru/1.0.0/),
и этот проект придерживается [Semantic Versioning](https://semver.org/lang/ru/).

## [Unreleased]

### Добавлено
- Node.js 20.x с npm для работы с frontend-инструментами
- Раздел в README о работе с Node.js и npm
- Обновлен .gitignore для игнорирования .idea и .DS_Store

### Изменено
- Улучшен процесс установки Node.js в Dockerfile (теперь используется официальный NodeSource репозиторий)
- Обновлен README.md с полным описанием возможностей образа

## [1.0.0] - 2026-01-15

### Добавлено
- Первоначальный релиз Docker-образа для October CMS 1.1.12
- PHP 7.4 с Apache
- Composer для управления зависимостями
- Настроенный cron для планировщика задач
- Вспомогательные команды: artisan, tinker, october
- Конфигурация через переменные окружения
- Поддержка SQLite, MySQL и PostgreSQL
- Docker Compose пример для быстрого запуска
- Подробная документация в README.md

