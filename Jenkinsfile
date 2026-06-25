pipeline {

    agent any

environment {
        // Configuraciones de la imagen de Docker
        REGISTRY_USER = "k1y0t4k4" // Reemplaza con tu usuario real de Docker Hub
        CODIGO_ESTUDIANTE = "u202314304" // Reemplaza con tu codigo de estudiante
        IMAGE_NAME = "retail-store-${CODIGO_ESTUDIANTE}"
        TAG = "latest"
    }

  stages {
        stage('1. Compilación y Pruebas Unitarias') {
            steps {
                echo "Compilando con Java 26 usando la imagen de Maven 3.9.16 del profesor..."
                // Usamos --volumes-from jenkins-master para que comparta la ruta exacta del código
                sh "docker run --rm --volumes-from jenkins-master -v maven_cache:/root/.m2 -w ${env.WORKSPACE} maven:3.9.16-eclipse-temurin-26-alpine mvn clean package"
            }
        }

        stage('2. Análisis de Calidad en SonarQube') {
            steps {
                echo "Enviando análisis a SonarQube..."
                withSonarQubeEnv('MiSonarServer') {
                    // Compartimos volúmenes e inyectamos las variables de entorno correctas para SonarQube
                    sh "docker run --rm --volumes-from jenkins-master -v maven_cache:/root/.m2 -w ${env.WORKSPACE} --network spring-postgres-net -e SONAR_HOST_URL=${env.SONAR_HOST_URL} -e SONAR_AUTH_TOKEN=${env.SONAR_AUTH_TOKEN} maven:3.9.16-eclipse-temurin-26-alpine mvn verify sonar:sonar"
                }
            }
        }

        stage('3. Verificación de Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('4. Construir y Publicar Imagen Docker') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        echo "Iniciando sesión en Docker Hub..."
                        sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"

                        echo "Construyendo y subiendo la imagen de producción..."
                        sh "docker buildx build --platform linux/amd64 -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} --push ."
                    }
                }
            }
        }
    }
}
