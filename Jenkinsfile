pipeline {
    agent any

    environment {
        REGISTRY_USER      = "k1y0t4k4"
        CODIGO_ESTUDIANTE  = "u202314304"
        IMAGE_NAME         = "retail-store-${CODIGO_ESTUDIANTE}"
        TAG                = "latest"
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
                sh 'chmod +x mvnw'
                withSonarQubeEnv('MiSonarServer') {
                    sh './mvnw verify sonar:sonar'
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
                withCredentials([usernamePassword(
                    credentialsId: 'DOCKER_HUB_CREDENTIALS',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
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

    post {
        always {
            sh 'docker logout || true'
        }
    }
}
