# Инструкция по развёртыванию SmartBoxAI на VPS

## Предварительные требования

- Docker и Docker Compose установлены на сервере
- Трафик на порты 80/443 обрабатывается через Traefik
- Есть доменное имя (опционально)

---

## Шаг 1: Подготовьте файлы

Загрузите файлы в директорию на сервере:

```bash
# Вариант A: Через Git (рекомендуется)
git clone <your-repo-url>
cd smartboxai

# Вариант B: Через SCP/SFTP
scp -r smartboxai/ user@your-server:/opt/smartboxai
```

---

## Шаг 2: Настройте webhook n8n (если ещё не настроен)

1. Откройте `index.html` и найдите строку:
   ```javascript
   const N8N_WEBHOOK_URL = 'https://your-n8n-instance.webhook.site/your-unique-id';
   ```

2. Замените на URL вашего webhook из n8n:
   ```javascript
   const N8N_WEBHOOK_URL = 'https://n8n.yourdomain.com/webhook/leads';
   ```

---

## Шаг 3: Настройте домен (опционально)

Отредактируйте `docker-compose.yml`:

```yaml
labels:
  - "traefik.http.routers.smartboxai.rule=Host(`smartboxai.yourdomain.com`)"
```

Замените `smartboxai.yourdomain.com` на ваш домен.

---

## Шаг 4: Проверьте сеть Traefik

```bash
# Узнайте имя сети Traefik
docker network ls

# Обычно это 'n8n_traefik-public' или 'traefik-public'
# Проверьте, что сеть существует
docker network inspect n8n_traefik-public
```

Если сеть не найдена, создайте её:

```bash
docker network create traefik-public
```

---

## Шаг 5: Соберите и запустите контейнер

```bash
cd /opt/smartboxai  # или куда вы загрузили файлы

# Сборка образа
docker-compose build

# Запуск
docker-compose up -d

# Проверка статуса
docker-compose ps
```

---

## Шаг 6: Проверьте работу

```bash
# Логи контейнера
docker-compose logs -f

# Проверка healthcheck
docker inspect smartboxai-frontend --format='{{json .State.Health.Status}}'
```

---

## Шаг 7: Проверьте доступность

```bash
# Через curl
curl -I http://localhost

# Или через браузер
# http://your-server-ip:8081 (если без Traefik)
# https://smartboxai.yourdomain.com (с Traefik + SSL)
```

---

## Обновление

```bash
# Загрузите новые файлы
git pull  # или scp новые файлы

# Пересоберите и перезапустите
docker-compose build
docker-compose up -d
```

---

## Остановка

```bash
docker-compose down
```

---

## Удаление

```bash
# Остановить
docker-compose down

# Удалить образ
docker rmi smartboxai-frontend

# Удалить файлы
rm -rf /opt/smartboxai
```

---

## Troubleshooting

### Контейнер не стартует

```bash
# Проверьте логи
docker-compose logs smartboxai

# Проверьте, свободен ли порт
docker-compose config
```

### Traefik не видит контейнер

```bash
# Проверьте метки
docker inspect smartboxai-frontend | grep traefik

# Убедитесь, что сеть правильная
docker network inspect traefik-public | grep smartboxai
```

### Проблемы с SSL

```bash
# Проверьте сертификаты Traefik
docker logs n8n-traefik-1 | grep -i cert

# Перезапустите Traefik (если нужно)
docker-compose -f /path/to/traefik-compose.yml restart
```

---

## Сетевая архитектура

```
Internet
    ↓
Port 80/443 (Traefik)
    ↓
smartboxai-frontend:80 (Nginx)
    ↓
index.html (статика)
```

---

## Порты

| Порт | Описание |
|------|----------|
| 80   | HTTP (через Traefik) |
| 443  | HTTPS (через Traefik) |
| Внутри контейнера | 80 (Nginx) |
