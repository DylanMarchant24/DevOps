# Stage 1: Compilación (Build)
FROM node:20-alpine AS builder
WORKDIR /app

# Optimización: Copiar package.json y package-lock.json para cachear dependencias
COPY package*.json ./
RUN npm ci

# Copiar el resto del código y construir la aplicación (Vite)
COPY . .
RUN npm run build

# Stage 2: Servir con Nginx (Run)
# Uso de la imagen unprivileged oficial de Nginx para cumplir con "Mínimo Privilegio"
FROM nginxinc/nginx-unprivileged:alpine

# Copiar los estáticos compilados desde el stage anterior al directorio de Nginx
COPY --from=builder /app/dist /usr/share/nginx/html

# Exponer puerto 8080 (los usuarios no-root no pueden usar el puerto 80 por defecto)
EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
