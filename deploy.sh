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

# Function to read user input
read_with_default() {
    local prompt="$1 (default: $2): "
    read -p "$prompt" value
    value=${value:-$2}
    echo "$value"
}

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

# Build CtrlLoveMigration Docker image
log_step "Building CtrlLoveMigration Docker image"
docker build -t ctrllovemigration:latest -f Migration.Dockerfile .

# Build CtrlLoveServer Docker image
log_step "Building CtrlLoveServer Docker image"
docker build -t ctrlloveserver:latest -f Dockerfile .

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
