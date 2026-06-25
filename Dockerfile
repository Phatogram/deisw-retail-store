# Etapa 1: Construcción (usando la imagen Maven con Temurin 26 que pidió tu profe)
FROM maven:3.9.6-eclipse-temurin-26-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Compilamos el proyecto creando el .jar
RUN mvn clean package -DskipTests

# Etapa 2: Ejecución (usando la imagen JRE 26 que pidió tu profe)
FROM eclipse-temurin:26-jre-alpine
WORKDIR /app
# Copiamos el .jar generado en la etapa anterior
COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

# Comando de arranque
ENTRYPOINT ["java", "-jar", "app.jar"]
