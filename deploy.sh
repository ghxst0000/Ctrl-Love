#!/bin/bash

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Please install Docker before running this script."
    exit 1
fi

# Log function to print steps
log_step() {
    local blue="\033[1;34m"
    local underline="\033[4m"
    local reset="\033[0m"
    echo -e "${blue}\tStep: ${underline}$1${reset}"
}

# Function to read user input with color
read_color() {
    local yellow="\033[1;33m"
    local reset="\033[0m"
    read -p "${yellow}$1${reset}" $2
}

# Get user input for the Database, PGpassword, and PGusername
read_color "Enter Database name (default: CtrlLove): " database_name
read_color "Enter PostgreSQL password (default: postgre): " pg_password
read_color "Enter PostgreSQL username (default: postgres): " pg_username

# Set default values if variables are empty (user pressed Enter)
database_name=${database_name:-CtrlLove}
pg_password=${pg_password:-postgre}
pg_username=${pg_username:-postgres}

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
