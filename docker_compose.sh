#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "Starting Docker and Docker Compose installation..."

# Install Docker
echo "Downloading Docker installation script..."
curl -fsSL https://get.docker.com -o install-docker.sh

echo "Making the script executable..."
sudo chmod +x install-docker.sh

echo "Running Docker installation script..."
sudo sh install-docker.sh

echo "Verifying Docker installation..."
docker --version

echo "Checking Docker service status..."
if sudo systemctl is-active --quiet docker; then
    echo "Docker is running."
else
    echo "Docker is NOT running. Starting Docker..."
    sudo systemctl start docker
fi

echo "Running a test Docker container..."
sudo docker run hello-world

echo "Adding current user ($USER) to the Docker group..."
sudo usermod -aG docker $USER

echo "Restarting Docker to apply group changes..."
sudo systemctl restart docker

echo "IMPORTANT: You must log out and back in (or reboot) for the group changes to take effect."
echo "Once logged back in, run: docker run hello-world"

# Install Docker Compose
DOCKER_COMPOSE_VERSION="v2.23.3"
DOCKER_COMPOSE_URL="https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)"

echo "Downloading Docker Compose (Version: ${DOCKER_COMPOSE_VERSION})..."
sudo curl -L "$DOCKER_COMPOSE_URL" -o /usr/local/bin/docker-compose

echo "Making Docker Compose executable..."
sudo chmod +x /usr/local/bin/docker-compose

echo "Verifying Docker Compose installation..."
docker-compose --version

# Enable Docker and containerd services
echo "Enabling Docker and containerd services to start on boot..."
sudo systemctl enable docker.service
sudo systemctl enable containerd.service

echo "Docker and Docker Compose installation completed successfully!"
