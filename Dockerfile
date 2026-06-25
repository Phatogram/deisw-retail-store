# ── Stage 1: Build ──────────────────────────────────────────────
FROM maven:3.9.16-eclipse-temurin-26-alpine AS builder

WORKDIR /app

# Copiamos primero solo el pom.xml para aprovechar el caché de Docker
COPY pom.xml .
# Si tienes un archivo .mvn o mvnw, impórtalos aquí. 
# Si solo usas 'mvn', comentamos o quitamos la línea del wrapper.
RUN mvn dependency:go-offline -B

# Ahora copiamos el código fuente
COPY src ./src

# Compilamos
RUN mvn clean package -DskipTests -B

# ── Stage 2: Runtime ────────────────────────────────────────────
FROM eclipse-temurin:26-jre-alpine

WORKDIR /app

# Copiamos solo el jar generado desde la etapa anterior
COPY --from=builder /app/target/*.jar app.jar

# Exponemos el puerto
EXPOSE 8096

# Comando de arranque
ENTRYPOINT ["java", "-jar", "app.jar"]
