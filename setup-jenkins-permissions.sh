#!/bin/bash

# Install Docker if not already installed
if ! command -v docker &> /dev/null; then
    echo "Installing Docker..."
    # Update package index
    sudo apt-get update
    
    # Install prerequisites
    sudo apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Set up the stable repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package index again
    sudo apt-get update
    
    # Install Docker Engine
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io
    
    # Start and enable Docker service
    sudo systemctl start docker
    sudo systemctl enable docker
fi

# Create Go installation directory with proper permissions
sudo mkdir -p /opt/go
sudo chown -R jenkins:jenkins /opt/go

# Add Jenkins user to docker group
sudo usermod -aG docker jenkins

# Create directory for Trivy repository
sudo mkdir -p /etc/apt/sources.list.d
sudo chown -R jenkins:jenkins /etc/apt/sources.list.d

# Create directory for GPG keys
sudo mkdir -p /tmp
sudo chown -R jenkins:jenkins /tmp

# Restart Jenkins to apply group changes
sudo systemctl restart jenkins

echo "Permissions have been set up for Jenkins user" 