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
        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USER')]) {
                    sh '''
                        set -e
                        printf '%s\n' "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin "$DOCKER_REGISTRY"
                        
                        # Build and push server image
                        docker build -t $IMAGE_SERVER:build-$BUILD_NUMBER ./serveur
                        docker tag $IMAGE_SERVER:build-$BUILD_NUMBER $IMAGE_SERVER:latest
                        docker push $IMAGE_SERVER:build-$BUILD_NUMBER
                        docker push $IMAGE_SERVER:latest
                        
                        # Build and push client image
                        docker build -t $IMAGE_CLIENT:build-$BUILD_NUMBER ./client
                        docker tag $IMAGE_CLIENT:build-$BUILD_NUMBER $IMAGE_CLIENT:latest
                        docker push $IMAGE_CLIENT:build-$BUILD_NUMBER
                        docker push $IMAGE_CLIENT:latest
                    '''
                }
            }
        }
        stage('Deploy') {
            steps {
                sh '''
                    # Set kubeconfig path
                    export KUBECONFIG=/root/.kube/config
                    
                    # Download kubectl
                    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                    chmod +x kubectl
                    
                    # Verify cluster connectivity
                    echo "Verifying Kubernetes cluster connectivity..."
                    ./kubectl cluster-info
                    
                    # Restart deployments to pull latest images
                    echo "Restarting deployments..."
                    ./kubectl rollout restart deployment client-deployment serveur-deployment
                    
                    # Wait for rollout to complete
                    echo "Waiting for rollout to complete..."
                    ./kubectl rollout status deployment client-deployment
                    ./kubectl rollout status deployment serveur-deployment
                '''
            }
        }
    }
}
