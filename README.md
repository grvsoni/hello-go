# hello-go

A simple Go web application that serves a static webpage on port 6001.

## Prerequisites

- Go 1.18 or later
- Docker (for container deployment)
- kubectl and a Kubernetes cluster (for K8s deployment)

## Local Deployment

### Mac OS (Apple Silicon)

1. Install Go:
   ```bash
   brew install go
   ```
   Or download from [Go's official website](https://golang.org/dl/)

2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd hello-go
   ```

3. Run the application:
   ```bash
   go run main.go
   ```

4. Access the application at http://localhost:6001

### Mac OS (Intel)

Follow the same steps as for Mac OS (Apple Silicon). Go is compatible with both architectures.

### Linux

1. Install Go:
   ```bash
   # For Ubuntu/Debian
   sudo apt-get update
   sudo apt-get install golang-go

   # For CentOS/RHEL
   sudo yum install golang

   # Or use the install script included in the repo
   ./install-go.sh
   ```

2. Clone the repository:
   ```bash
   git clone <repository-url>
   cd hello-go
   ```

3. Run the application:
   ```bash
   go run main.go
   ```

4. Access the application at http://localhost:6001

## Docker Deployment

### Build the Docker image

```bash
cd hello-go
docker build -t hello-go .
```

### Tag and Push the Docker image

```bash
# Tag the image for the repository
docker tag hello-go grvsoniharness/hello-go:latest

# Login to Docker Hub (if not already logged in)
docker login

# Push the image to Docker Hub
docker push grvsoniharness/hello-go:latest
```

### Run the Docker container

```bash
# Run using local image
docker run -p 6001:6001 hello-go

# Or run using the pushed image
docker run -p 6001:6001 grvsoniharness/hello-go:latest
```

**Note:** The application inside the Docker container runs on port 6001. Access the application at http://localhost:6001 when running via Docker.

## Kubernetes Deployment

### Kubernetes Manifests

Kubernetes manifests have been provided in the `k8s/` directory, separated into four files:

1. `namespace.yaml` - Defines the `hello-go` namespace
2. `deployment.yaml` - Configures a deployment with resource limits/requests and 3 replicas of the application
3. `service.yaml` - Creates a LoadBalancer service to expose the application on port 6001
4. `autoscaler.yaml` - Configures a Horizontal Pod Autoscaler (HPA) to automatically scale the application based on CPU and memory usage

### Deploy to Kubernetes

1. Make sure your Docker image is accessible to your Kubernetes cluster

2. Apply the Kubernetes manifests:
   ```bash
   # Apply all files at once
   kubectl apply -f k8s/
   
   # Or apply them individually in the proper order
   kubectl apply -f k8s/namespace.yaml
   kubectl apply -f k8s/deployment.yaml
   kubectl apply -f k8s/service.yaml
   kubectl apply -f k8s/autoscaler.yaml
   ```

3. Check the deployment status:
   ```bash
   kubectl get namespace hello-go
   kubectl get deployments -n hello-go
   kubectl get pods -n hello-go
   kubectl get services -n hello-go
   kubectl get hpa -n hello-go
   ```

   To see detailed information about the autoscaler:
   ```bash
   kubectl describe hpa hello-go-hpa -n hello-go
   ```

4. Access the application:
   - If using a cloud provider with LoadBalancer support: Access the external IP shown in `kubectl get services -n hello-go`
   ```bash
   kubectl get services -n hello-go
   ```
   
   - If using Minikube: 
   ```bash
   minikube service hello-go -n hello-go
   ```
   
   - If using a local cluster without LoadBalancer support: Port-forward to access the service: 
   ```bash
   kubectl port-forward svc/hello-go 6001:6001 -n hello-go
   ```
   Then access at http://localhost:6001

## Development

### Running Tests

```bash
go test ./...
```
