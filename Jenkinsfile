pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_USERNAME = 'iheb1603'
        REPO_NAME = 'monapp'
        IMAGE_SERVER = "${DOCKER_USERNAME}/${REPO_NAME}-serveur"
        IMAGE_CLIENT = "${DOCKER_USERNAME}/${REPO_NAME}-client"
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "=== Checkout du code depuis Git ==="
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                echo "=== Build et tests inclus dans Dockerfile multi-stage ==="
            }
        }

        stage('Docker Build Images') {
            steps {
                script {
                    def imageTag = "build-${env.BUILD_NUMBER}"

                    echo "=== Build de l'image Serveur ==="
                    sh "docker build -t ${IMAGE_SERVER}:${imageTag} ./serveur"
                    sh "docker tag ${IMAGE_SERVER}:${imageTag} ${IMAGE_SERVER}:latest"

                    echo "=== Build de l'image Client ==="
                    sh "docker build -t ${IMAGE_CLIENT}:${imageTag} ./client"
                    sh "docker tag ${IMAGE_CLIENT}:${imageTag} ${IMAGE_CLIENT}:latest"
                }
            }
        }

        stage('Docker Push to Registry') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
                    script {
                        sh "echo \"${DOCKER_PASSWORD}\" | docker login -u ${DOCKER_USER} --password-stdin ${DOCKER_REGISTRY}"

                        def imageTag = "build-${env.BUILD_NUMBER}"

                        sh "docker push ${IMAGE_SERVER}:${imageTag}"
                        sh "docker push ${IMAGE_SERVER}:latest"
                        sh "docker push ${IMAGE_CLIENT}:${imageTag}"
                        sh "docker push ${IMAGE_CLIENT}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                echo "=== Mise à jour des manifestes Kubernetes ==="
                sh "sed -i 's|image: .*monapp-serveur:.*|image: ${IMAGE_SERVER}:build-${env.BUILD_NUMBER}|g' ci-cd-config/k8s-serveur-deployment.yaml"
                sh "sed -i 's|image: .*monapp-client:.*|image: ${IMAGE_CLIENT}:build-${env.BUILD_NUMBER}|g' ci-cd-config/k8s-client-deployment.yaml"

                echo "=== Déploiement sur le cluster Kubernetes ==="
                sh "kubectl apply -f ci-cd-config/k8s-serveur-deployment.yaml"
                sh "kubectl apply -f ci-cd-config/k8s-client-deployment.yaml"
            }
        }
    }

    post {
        always {
            echo "=== Nettoyage des images Docker locales ==="
            sh "docker rmi -f ${IMAGE_SERVER}:build-${env.BUILD_NUMBER} ${IMAGE_SERVER}:latest || true"
            sh "docker rmi -f ${IMAGE_CLIENT}:build-${env.BUILD_NUMBER} ${IMAGE_CLIENT}:latest || true"

            echo "=== Pipeline terminé ==="
        }
        failure {
            echo "=== Pipeline échoué ==="
        }
    }
}
