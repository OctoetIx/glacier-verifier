#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y

echo "==== Welcome to the Glacier Verifier Node Setup Script ===="
fi
# Update and install necessary packages
echo "Updating system and installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release wget

# Check if Docker is installed
echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    sudo apt install -y docker.io
    sudo systemctl start docker
    sudo systemctl enable docker
else
    echo "Docker is already installed."
fi
docker --version

# Check if Docker Compose is installed
echo "Checking if Docker Compose is installed..."
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing Docker Compose..."
    sudo apt install -y docker-compose
else
    echo "Docker Compose is already installed."
fi


# Check if Screen is installed
echo "Checking if Screen is installed..."
if ! command -v screen &> /dev/null; then
    echo "Screen is not installed. Installing Screen..."
    sudo apt install screen -y
else
    echo "Screen is already installed."
fi
#Create Screen
echo "Creating Screen "
screen -S glacier

# Prompt for Private Key
echo "Please enter your private key for the Glacier Verifier Node:"
read -s PRIVATE_KEY

# Validate Private Key
if [ -z "$PRIVATE_KEY" ]; then
    echo "Private key is required to proceed. Exiting."
    exit 1
fi

# Pull and Run Glacier Verifier Node
echo "Pulling and running Glacier Verifier Node Docker container..."
docker pull docker.io/glaciernetwork/glacier-verifier:v0.0.1
docker run -d -e PRIVATE_KEY=$PRIVATE_KEY --name glacier-verifier docker.io/glaciernetwork/glacier-verifier:v0.0.1

# Check if the container is running
if docker ps | grep -q "glacier-verifier"; then
    echo "Glacier Verifier Node is running successfully!"
    echo "Use 'docker logs -f glacier-verifier' to monitor the node logs."
else
    echo "Failed to start the Glacier Verifier Node. Check the Docker logs for details."
fi

echo "==== Setup Complete ===="