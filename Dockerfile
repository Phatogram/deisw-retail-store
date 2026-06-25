# ── Stage 1: Build ──────────────────────────────────────────────
FROM maven:3.9.16-eclipse-temurin-26-alpine AS builder
WORKDIR /app
COPY pom.xml .
RUN ./mvnw dependency:go-offline -B || mvn dependency:go-offline -B
COPY . .
RUN mvn clean package -DskipTests -B

# ── Stage 2: Runtime ────────────────────────────────────────────
FROM eclipse-temurin:26-jre-alpine
WORKDIR /app
COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8096
ENTRYPOINT ["java", "-jar", "app.jar"]
