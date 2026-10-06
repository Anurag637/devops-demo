#!/usr/bin/env bash
# ==============================================================================
# Automated Deployment Script for Jenkins CI/CD Pipeline
# Author: Anurag Pandey | B.Tech CSE | Lab 1
# ==============================================================================

set -e

APP_NAME=${1:-"devops-ci-app"}
PORT=${2:-"5000"}

echo "---------------------------------------------------------"
echo ">>> Initiating Automated Deployment for: ${APP_NAME}"
echo "---------------------------------------------------------"

# 1. Stop and remove existing container if running
if [ "$(docker ps -q -f name=${APP_NAME})" ]; then
    echo ">>> Stopping existing container: ${APP_NAME}..."
    docker stop ${APP_NAME}
fi

if [ "$(docker ps -aq -f name=${APP_NAME})" ]; then
    echo ">>> Removing previous container instance: ${APP_NAME}..."
    docker rm ${APP_NAME}
fi

# 2. Run new container from latest built image
echo ">>> Launching new container instance on port ${PORT}..."
docker run -d --name ${APP_NAME} -p ${PORT}:5000 ${APP_NAME}:latest

# 3. Post-deployment Health Check Validation
echo ">>> Pausing 3 seconds for container warmup..."
sleep 3

echo ">>> Performing automated health check on http://localhost:${PORT}/health..."
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:${PORT}/health || echo "FAILED")

if [ "$HTTP_STATUS" -eq 200 ]; then
    echo ">>> [SUCCESS] Health check passed with HTTP 200 OK!"
    echo ">>> Application is live and healthy at http://localhost:${PORT}"
    exit 0
else
    echo ">>> [ERROR] Health check failed with status: ${HTTP_STATUS}"
    echo ">>> Initiating deployment rollback..."
    docker stop ${APP_NAME} || true
    docker rm ${APP_NAME} || true
    exit 1
fi
