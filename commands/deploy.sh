#!/bin/bash

# Exit the script immediately if any command exits with a non-zero status
set -e

# Function to handle errors with custom messages
handle_error() {
    echo "Error: $1"
    exit 1
}

# Navigate to the application directory
cd /home/ubuntu/src/py-fastapi-homework-5-ec2-deploy-task || handle_error "Failed to navigate to the application directory."

# Ensure there is no git lock file that could block operations
echo "🧹  Checking and removing potential Git lock files..."
if [ -f .git/index.lock ]; then
    echo "Found .git/index.lock — removing it..."
    rm -f .git/index.lock || handle_error "Failed to remove .git/index.lock"
fi

rm -f .git/refs/remotes/origin/main .git/refs/remotes/origin/main.lock || true

# Give the system a short break (helps with filesystem syncs in rare cases)
sleep 1

# Fetch the latest changes from the remote repository
echo "Fetching the latest changes from the remote repository..."
git fetch --prune origin main || handle_error "Failed to fetch updates from the 'origin' remote."

# Reset the local repository to match the remote 'main' branch
echo "Resetting the local repository to match 'origin/main'..."
git reset --hard origin/main || handle_error "Failed to reset the local repository to 'origin/main'."

# (Optional) Pull any new tags from the remote repository
echo "Fetching tags from the remote repository..."
git fetch origin --tags || handle_error "Failed to fetch tags from the 'origin' remote."

# Stop and remove existing containers
echo "🧹 Stopping and removing existing containers..."
docker compose -f docker-compose-prod.yml down --remove-orphans -v || handle_error "Failed to stop and remove old containers."

# Build and run Docker containers with Docker Compose v2
echo "🚀 Building and running Docker containers..."
docker compose -f docker-compose-prod.yml up -d --build --force-recreate --remove-orphans || handle_error "Failed to build and run Docker containers using docker-compose-prod.yml."

# Print a success message upon successful deployment
echo "✅ Deployment completed successfully."
