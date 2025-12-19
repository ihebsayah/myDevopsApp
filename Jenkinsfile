pipeline {
    agent any

    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_USERNAME = 'iheb1603' // <- Ton nom d'utilisateur Docker Hub
        REPO_NAME = 'monapp'          // <- Nom de ton application
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
                script {
                    echo "=== Build et tests inclus dans Dockerfile multi-stage ==="
                    // Si tu veux ajouter des tests locaux avant Docker build, tu peux le faire ici
                }
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
                        echo "=== Login Docker Hub ==="
                        sh "echo \"${DOCKER_PASSWORD}\" | docker login -u ${DOCKER_USER} --password-stdin ${DOCKER_REGISTRY}"

                        def imageTag = "build-${env.BUILD_NUMBER}"

                        echo "=== Push de l'image Serveur ==="
                        sh "docker push ${IMAGE_SERVER}:${imageTag}"
                        sh "docker push ${IMAGE_SERVER}:latest"

                        echo "=== Push de l'image Client ==="
                        sh "docker push ${IMAGE_CLIENT}:${imageTag}"
                        sh "docker push ${IMAGE_CLIENT}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def imageTag = "build-${env.BUILD_NUMBER}"

                    echo "=== Mise à jour des images dans Kubernetes ==="
                    sh "kubectl set image deployment/serveur-deployment serveur=${IMAGE_SERVER}:${imageTag} --record"
                    sh "kubectl set image deployment/client-deployment client=${IMAGE_CLIENT}:${imageTag} --record"

                    echo "=== Appliquer les manifests (si nécessaire) ==="
                    sh "kubectl apply -f ci-cd-config/k8s-serveur-deployment.yaml || true"
                    sh "kubectl apply -f ci-cd-config/k8s-client-deployment.yaml || true"
                }
            }
        }
    }

    post {
        always {
            echo "=== Nettoyage des images Docker locales ==="
            sh "docker rmi ${IMAGE_SERVER}:${env.BUILD_NUMBER} ${IMAGE_SERVER}:latest || true"
            sh "docker rmi ${IMAGE_CLIENT}:${env.BUILD_NUMBER} ${IMAGE_CLIENT}:latest || true"
        }
        success {
            echo "=== Pipeline terminé avec succès ==="
        }
        failure {
            echo "=== Pipeline échoué ==="
        }
    }
}
