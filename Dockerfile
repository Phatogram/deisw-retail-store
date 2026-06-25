# Etapa 1: Construcción (Build) usando el wrapper de Maven y OpenJDK 26
FROM eclipse-temurin:26-jdk-alpine AS build
WORKDIR /app
# Copiamos los archivos de configuración de Maven
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
# Le damos permisos de ejecución al wrapper
RUN chmod +x mvnw
# Descargamos las dependencias (mejora el caché de Docker)
RUN ./mvnw dependency:go-offline

# Copiamos el código fuente y compilamos
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Etapa 2: Ejecución (Run)
FROM eclipse-temurin:26-jre-alpine
WORKDIR /app
# Copiamos el .jar generado en la etapa anterior
COPY --from=build /app/target/*.jar app.jar

# Exponemos el puerto por defecto de Spring Boot
EXPOSE 8080

# Comando para ejecutar la aplicación
ENTRYPOINT ["java", "-jar", "app.jar"]
