#!/bin/bash

# Function to log steps
log_step() {
    echo "Step: $1"
}

# Function to read user input with a default value
read_with_default() {
    local prompt="$1 (default: $2): "
    read -p "$prompt" value
    value=${value:-$2}
    echo "$value"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Get user input for the Database, PGpassword, and PGusername
database_name=$(read_with_default "Enter Database name" "CtrlLove")
pg_password=$(read_with_default "Enter PostgreSQL password" "postgre")
pg_username=$(read_with_default "Enter PostgreSQL username" "postgres")

# Create the Docker network
log_step "Creating Docker network 'ctrl_love_network'"
docker network create ctrl_love_network

# Run the PostgreSQL container with the specified password and environment variables
log_step "Running PostgreSQL container"
docker run -d --name postgres_container --network ctrl_love_network \
    -e POSTGRES_PASSWORD=$pg_password -e POSTGRES_DB=$database_name -e POSTGRES_USER=$pg_username \
    postgres

# Get the IP address of the PostgreSQL container
postgres_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' postgres_container)

# Function to build a Docker image with error handling
build_docker_image() {
    local image_name="$1"
    local dockerfile="$2"
    log_step "Building $image_name Docker image"
    if docker build -t "$image_name:latest" -f "$dockerfile" .; then
        echo "$image_name Docker image built successfully."
    else
        echo "Error: Failed to build $image_name Docker image."
    fi
}

# Build CtrlLoveMigration Docker image
build_docker_image "ctrllovemigration" "Migration.Dockerfile"

# Build CtrlLoveServer Docker image
build_docker_image "ctrlloveserver" "Dockerfile"

# Run CtrlLoveMigration container with PostgreSQL IP and environment variables
log_step "Running CtrlLoveMigration container"
docker run --rm --network ctrl_love_network \
    -e POSTGRES_HOST=$postgres_ip -e POSTGRES_DB=$database_name \
    -e POSTGRES_USER=$pg_username -e POSTGRES_PASSWORD=$pg_password \
    ctrllovemigration:latest

# Run CtrlLoveServer container with PostgreSQL IP and environment variables
log_step "Running CtrlLoveServer container"
docker run -d --name my_app_container -p 8080:80 --network ctrl_love_network \
    -e POSTGRES_HOST=$postgres_ip -e POSTGRES_DB=$database_name \
    -e POSTGRES_USER=$pg_username -e POSTGRES_PASSWORD=$pg_password \
    ctrlloveserver:latest

echo "Setup completed successfully!"
