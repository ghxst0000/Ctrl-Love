#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Log function to print steps
log_step() {
    echo "Step: $1"
}

# Create the Docker network
log_step "Creating Docker network 'ctrl_love_network'"
docker network create ctrl_love_network

# Pull PostgreSQL image
log_step "Pulling PostgreSQL image"
docker pull postgres

# Run the PostgreSQL container
log_step "Running PostgreSQL container"
docker run -d --name postgres_container --network ctrl_love_network -e POSTGRES_PASSWORD=mysecretpassword postgres

# Build CtrlLoveMigration Docker image
log_step "Building CtrlLoveMigration Docker image"
docker build -t CtrlLoveMigration:latest -f Migration.Dockerfile .

# Build CtrlLoveServer Docker image
log_step "Building CtrlLoveServer Docker image"
docker build -t CtrlLoveServer:latest -f Dockerfile .

# Run CtrlLoveMigration container
log_step "Running CtrlLoveMigration container"
docker run --rm --network ctrl_love_network CtrlLoveMigration:latest

# Run CtrlLoveServer container
log_step "Running CtrlLoveServer container"
docker run -d --name my_app_container -p 8080:80 --network ctrl_love_network CtrlLoveServer:latest

echo "Setup completed successfully!"