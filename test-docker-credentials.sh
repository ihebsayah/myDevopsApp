#!/bin/bash

# Docker Hub Credentials Test Script
# This script helps you verify your Docker Hub credentials work correctly

echo "=================================="
echo "Docker Hub Credentials Test"
echo "=================================="
echo ""

# Prompt for credentials
read -p "Enter your Docker Hub username [iheb1603]: " DOCKER_USER
DOCKER_USER=${DOCKER_USER:-iheb1603}

echo ""
echo "Enter your Docker Hub access token (or password):"
read -s DOCKER_TOKEN
echo ""

# Test login
echo "Testing Docker Hub login..."
echo "$DOCKER_TOKEN" | docker login -u "$DOCKER_USER" --password-stdin docker.io

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ SUCCESS! Your Docker Hub credentials are valid."
    echo ""
    echo "Next steps:"
    echo "1. Copy your access token"
    echo "2. Open Jenkins at http://localhost:8080"
    echo "3. Go to: Manage Jenkins → Credentials → System → Global credentials"
    echo "4. Update 'docker-hub-credentials' with:"
    echo "   - Username: $DOCKER_USER"
    echo "   - Password: <your access token>"
    echo ""
    
    # Logout
    docker logout docker.io
else
    echo ""
    echo "❌ FAILED! Your credentials are incorrect."
    echo ""
    echo "Please:"
    echo "1. Verify your username is correct"
    echo "2. Create a new Personal Access Token at:"
    echo "   https://hub.docker.com/settings/security"
    echo "3. Make sure the token has Read, Write, Delete permissions"
    echo ""
fi
