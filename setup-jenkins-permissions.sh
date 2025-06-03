#!/bin/bash

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