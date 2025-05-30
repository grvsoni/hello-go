pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'hello-go'
        DOCKER_TAG = "${BUILD_NUMBER}"
        KUBE_NAMESPACE = 'hello-go'
        KUBE_CONFIG = credentials('k8s-config')
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Build') {
            steps {
                sh 'go build -o main'
            }
        }
        
        stage('Test') {
            steps {
                sh 'go test ./...'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    try {
                        sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                        sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
                    } catch (Exception e) {
                        echo "Failed to build Docker image: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Deploy to Kubernetes') {
            steps {
                script {
                    try {
                        // Create namespace if it doesn't exist
                        sh """
                            kubectl --kubeconfig=${KUBE_CONFIG} create namespace ${KUBE_NAMESPACE} --dry-run=client -o yaml | kubectl --kubeconfig=${KUBE_CONFIG} apply -f -
                        """
                        
                        // Update deployment with new image
                        sh """
                            sed -i 's|image: hello-go:latest|image: ${DOCKER_IMAGE}:${DOCKER_TAG}|g' k8s/deployment.yaml
                            kubectl --kubeconfig=${KUBE_CONFIG} apply -f k8s/deployment.yaml
                        """
                        
                        // Wait for deployment to roll out
                        sh """
                            kubectl --kubeconfig=${KUBE_CONFIG} rollout status deployment/hello-go -n ${KUBE_NAMESPACE}
                        """
                    } catch (Exception e) {
                        echo "Failed to deploy to Kubernetes: ${e.message}"
                        throw e
                    }
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
} 