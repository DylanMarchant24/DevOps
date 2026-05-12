# Stage 1: Compilación (Build)
FROM maven:3.9.6-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Optimización: Copiar solo el pom.xml primero para aprovechar la caché de capas de Docker
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar el código fuente y compilar
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Ejecución (Run)
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Mínimo Privilegio: Crear y usar un usuario de sistema limitado, sin permisos de root
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copiar solo el artefacto final desde el stage de compilación
COPY --from=builder /app/target/*.jar app.jar

# Exponer el puerto por defecto de Spring Boot
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
