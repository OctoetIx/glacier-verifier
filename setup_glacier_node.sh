#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

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

# Create Screen session
echo "Creating Screen session..."
screen -S glacier -dm bash

# Create the Glacier directory
mkdir -p ~/glacier

# Download verifier
echo "Downloading the verifier..."
wget https://github.com/Glacier-Labs/node-bootstrap/releases/download/v0.0.1-beta/verifier_linux_amd64 -O ~/glacier/verifier_linux_amd64

# Request Private Key input
read -p "Enter your Private Key: " private_key

# Create a config.yaml file
cat << EOF > ~/glacier/config.yaml
Http:
  Listen: "127.0.0.1:10801"
Network: "testnet"
RemoteBootstrap: "https://glacier-labs.github.io/node-bootstrap/"
Keystore:
  PrivateKey: "$private_key"
TEE:
  IpfsURL: "https://greenfield.onebitdev.com/ipfs/"
EOF

# Change permissions of the verifier file
chmod +x ~/glacier/verifier_linux_amd64

# Create configuration directory and set permissions
sudo mkdir -p /etc/glaciernetwork
sudo cp ~/glacier/config.yaml /etc/glaciernetwork/config
sudo chmod 644 /etc/glaciernetwork/config

# Create a systemd service file
echo "Creating systemd service file..."
cat << EOF | sudo tee /etc/systemd/system/glacier.service
[Unit]
Description=Glacier Node Service
After=network.target

[Service]
ExecStart=$(realpath ~/glacier/verifier_linux_amd64)
Restart=on-failure
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the service
echo "Setting up Glacier as a systemd service..."
sudo systemctl daemon-reload
sudo systemctl enable glacier.service
sudo systemctl start glacier.service

echo "Your Glacier node is ready to run as a systemd service!"
echo "Monitor logs using: journalctl -u glacier.service -f"