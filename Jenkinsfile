pipeline {

    agent any

environment {
        // Configuraciones de la imagen de Docker
        REGISTRY_USER = "tu_usuario_dockerhub" // Reemplaza con tu usuario real de Docker Hub
        CODIGO_ESTUDIANTE = "u202314304" // Reemplaza con tu codigo de estudiante
        IMAGE_NAME = "retail-store-${CODIGO_ESTUDIANTE}"
        TAG = "latest"
    }

    stages {
        stage('1. Compilación y Pruebas Unitarias') {
            steps {
                echo "Compilando el proyecto y ejecutando pruebas..."
                sh 'chmod +x mvnw'
                sh './mvnw clean package'
            }
        }

        stage('2. Análisis de Calidad en SonarQube') {
            steps {
                echo "Enviando análisis a SonarQube..."
                // 'MiSonarServer' es el nombre que le diste al servidor en la configuración de Jenkins (Paso 3 de tu guía)
                withSonarQubeEnv('MiSonarServer') {
                    sh './mvnw verify sonar:sonar'
                }
            }
        }

        stage('3. Verificación de Quality Gate') {
            steps {
                timeout(time: 10, unit: 'MINUTES') {
                    // Jenkins esperará a que el Webhook de SonarQube le envíe la respuesta
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('4. Construir y Publicar Imagen Docker') {
            steps {
                // Nos autenticamos de forma segura en Docker Hub usando el ID de credenciales de Jenkins
                withCredentials([usernamePassword(credentialsId: 'DOCKER_HUB_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    script {
                        echo "Iniciando sesión en Docker Hub..."
                        sh "echo '${DOCKER_PASS}' | docker login -u '${DOCKER_USER}' --password-stdin"

                        echo "Construyendo y subiendo la imagen optimizada AMD64..."
                        sh "docker buildx build --platform linux/amd64 -t ${REGISTRY_USER}/${IMAGE_NAME}:${TAG} --push ."
                    }
                }
            }
        }
    }
}
