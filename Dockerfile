FROM nginx:alpine

# Копируем конфигурацию Nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Копируем статические файлы
COPY index.html /usr/share/nginx/html/

# Открываем порт (будет проброшен через Traefik)
EXPOSE 80

# healthcheck для Traefik
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost/ || exit 1

# Запускаем Nginx
CMD ["nginx", "-g", "daemon off;"]
