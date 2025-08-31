#!/bin/bash
# Este script actualiza el repositorio, reconstruye y reinicia los contenedores de Docker.
whoami
# Navegar al directorio del proyecto
cd /opt/repositorio/bahias-front
# Actualizar el repositorio
git pull origin main
# Construir y reiniciar los contenedores de Docker
docker compose build
docker compose down 
docker compose up -d

# Limpiar recursos no utilizados de Docker
docker builder prune -f 
docker image prune -f

# Enviar una notificación de que el despliegue ha finalizado
echo "Despliegue completado"
