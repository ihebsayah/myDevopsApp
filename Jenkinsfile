pipeline {
    agent any
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_USERNAME = 'iheb1603'  // <--- À CHANGER : Votre Docker Hub username
        REPO_NAME = 'monapp'          // <--- À CHANGER : Nom de votre application
        IMAGE_SERVER = "${DOCKER_USERNAME}/${REPO_NAME}-serveur"
        IMAGE_CLIENT = "${DOCKER_USERNAME}/${REPO_NAME}-client"
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Shallow clone pour éviter les timeouts
                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: '*/main']], 
                    doGenerateSubmoduleConfigurations: false, 
                    extensions: [[$class: 'CloneOption', shallow: true, timeout: 30]], 
                    userRemoteConfigs: [[url: 'https://github.com/ihebsayah/myDevopsApp']]
                ])
            }
        }
        
        stage('Build & Test') {
            steps {
                script {
                    echo "Compilation des binaires incluse dans l'étape Docker Build Multi-Stage."
                }
            }
        }
        
        stage('Docker Build Images') {
            steps {
                script {
                    def imageTag = "build-${env.BUILD_NUMBER}"
                    
                    echo "=== Build Serveur ==="
                    sh "docker build -t ${IMAGE_SERVER}:${imageTag} ./serveur"
                    sh "docker tag ${IMAGE_SERVER}:${imageTag} ${IMAGE_SERVER}:latest"
                    
                    echo "=== Build Client ==="
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
                        
                        // Push les images
                        sh "docker push ${IMAGE_SERVER}:${imageTag}"
                        sh "docker push ${IMAGE_CLIENT}:${imageTag}"
                        
                        // Push latest
                        sh "docker push ${IMAGE_SERVER}:latest"
                        sh "docker push ${IMAGE_CLIENT}:latest"
                    }
                }
            }
        }

        stage('De
