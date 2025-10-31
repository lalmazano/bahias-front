# Etapa 1: build con Flutter
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
RUN flutter config --enable-web

# Cachear dependencias
COPY ./bahias_app/pubspec.yaml  ./
COPY ./bahias_app/pubspec.lock* ./
RUN flutter pub get

# Copiar el resto del código y compilar
COPY ./bahias_app .
RUN flutter build web --release

# Etapa 2: Nginx para servir estático
#FROM nginx:alpine
#COPY --from=build /app/build/web /usr/share/nginx/html
#EXPOSE 80

# Etapa 2: Nginx para servir estático con HTTPS
FROM nginx:alpine

# Copiar archivos de la app
COPY --from=build /app/build/web /usr/share/nginx/html

# Copiar configuración personalizada
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copiar certificados al contenedor
COPY ./fullchain.pem /etc/ssl/certs/fullchain.pem
COPY ./privkey.pem /etc/ssl/private/privkey.pem

EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
