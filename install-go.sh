#!/bin/bash

# Download and install Go
GO_VERSION="1.24.3"
wget https://go.dev/dl/go${GO_VERSION}.darwin-arm64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.darwin-arm64.tar.gz
rm go${GO_VERSION}.darwin-arm64.tar.gz

# Add Go to PATH for Jenkins
echo 'export PATH=$PATH:/usr/local/go/bin' | sudo tee -a /etc/profile.d/go.sh
sudo chmod +x /etc/profile.d/go.sh

# Add Go to PATH for current user
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

# Verify installation
/usr/local/go/bin/go version 