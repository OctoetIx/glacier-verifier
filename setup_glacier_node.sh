#!/bin/bash

# Update system packages
sudo apt update && sudo apt upgrade -y
fi

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

# Create the Glacier directory
mkdir -p ~/glacier

# Download verifier
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

# Change the permissions of the verifier file so that it can be executed
chmod +x ~/glacier/verifier_linux_amd64

# Create a directory for configuration in /etc
sudo mkdir -p /etc/glaciernetwork

# Copy the configuration file to the right location
sudo cp ~/glacier/config.yaml /etc/glaciernetwork/config

# Create a systemd configuration file
cat << EOF | sudo tee /etc/systemd/system/glacier.service
[Units]
Description=Glacier Node Service
After=network. target

[Service]
ExecStart=/root/glacier/verifier_linux_amd64
Restart=on-failure
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and enable services
sudo systemctl daemon-reload
sudo systemctl enable glacier.service
sudo systemctl start glacier.service

echo "Your node is ready to run as a systemd service!"
echo "You can monitor the logs with the command: journalctl -u glacier.service -f"