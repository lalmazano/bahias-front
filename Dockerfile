# Etapa 1: build con Flutter
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app
RUN flutter config --enable-web

# Cachear dependencias
COPY pubspec.yaml pubspec.lock* ./
RUN flutter pub get

# Copiar el resto del código y compilar
COPY . .
RUN flutter build web --release

# Etapa 2: Nginx para servir estático
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
