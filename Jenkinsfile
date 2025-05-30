pipeline {
    agent any
    
    environment {
        DOCKER_IMAGE = 'grvsoni/hello-go'
        DOCKER_TAG = "${BUILD_NUMBER}"
        GIT_COMMIT_SHORT = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
        PATH = "/opt/homebrew/bin:/Users/gaurav/.rd/bin:${env.PATH}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    try {
                        // Install TruffleHog if not present
                        sh """
                            if ! command -v trufflehog &> /dev/null; then
                                echo "Installing TruffleHog..."
                                brew install trufflehog
                            fi
                        """
                        
                        // Run TruffleHog scan
                        sh """
                            echo "Starting security scan..."
                            trufflehog --only-verified --format json . > trufflehog-results.json || true
                            
                            # Check if any secrets were found
                            if [ -s trufflehog-results.json ]; then
                                echo "WARNING: Potential secrets found in the codebase!"
                                cat trufflehog-results.json
                                currentBuild.result = 'UNSTABLE'
                            else
                                echo "No secrets found in the codebase."
                            fi
                        """
                    } catch (Exception e) {
                        echo "Security scan failed: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
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
        
        stage('Build and Push Docker Image') {
            steps {
                script {
                    try {
                        // Build the image with multiple tags
                        sh "/Users/gaurav/.rd/bin/docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} -t ${DOCKER_IMAGE}:${GIT_COMMIT_SHORT} -t ${DOCKER_IMAGE}:latest ."
                        
                        // Login to DockerHub
                        withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', 
                                                       usernameVariable: 'DOCKER_USER', 
                                                       passwordVariable: 'DOCKER_PASS')]) {
                            sh "echo ${DOCKER_PASS} | /Users/gaurav/.rd/bin/docker login -u ${DOCKER_USER} --password-stdin"
                        }
                        
                        // Push all tags
                        sh "/Users/gaurav/.rd/bin/docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "/Users/gaurav/.rd/bin/docker push ${DOCKER_IMAGE}:${GIT_COMMIT_SHORT}"
                        sh "/Users/gaurav/.rd/bin/docker push ${DOCKER_IMAGE}:latest"
                        
                        // Logout from DockerHub
                        sh "/Users/gaurav/.rd/bin/docker logout"
                        
                        // Print version information
                        echo """
                        Image versions pushed to DockerHub:
                        - ${DOCKER_IMAGE}:${DOCKER_TAG} (Build number)
                        - ${DOCKER_IMAGE}:${GIT_COMMIT_SHORT} (Git commit)
                        - ${DOCKER_IMAGE}:latest (Latest version)
                        """
                    } catch (Exception e) {
                        echo "Failed to build or push Docker image: ${e.message}"
                        throw e
                    }
                }
            }
        }
        
        stage('Container Security Scan') {
            steps {
                script {
                    try {
                        // Install Trivy if not present
                        sh """
                            if ! command -v trivy &> /dev/null; then
                                echo "Installing Trivy..."
                                brew install trivy
                            fi
                        """
                        
                        // Run Trivy scan on the image
                        sh """
                            echo "Starting container security scan..."
                            
                            # Scan for vulnerabilities
                            trivy image --format json --output trivy-vuln.json ${DOCKER_IMAGE}:${DOCKER_TAG}
                            
                            # Scan for misconfigurations
                            trivy config --format json --output trivy-config.json .
                            
                            # Check if any critical or high vulnerabilities were found
                            if grep -q '"Severity":"CRITICAL"\\|"Severity":"HIGH"' trivy-vuln.json; then
                                echo "WARNING: Critical or High vulnerabilities found in the container image!"
                                cat trivy-vuln.json
                                currentBuild.result = 'UNSTABLE'
                            else
                                echo "No critical or high vulnerabilities found in the container image."
                            fi
                            
                            # Check for misconfigurations
                            if [ -s trivy-config.json ]; then
                                echo "WARNING: Misconfigurations found in the container!"
                                cat trivy-config.json
                                currentBuild.result = 'UNSTABLE'
                            else
                                echo "No misconfigurations found in the container."
                            fi
                        """
                    } catch (Exception e) {
                        echo "Container security scan failed: ${e.message}"
                        currentBuild.result = 'UNSTABLE'
                    }
                }
            }
        }
    }
    
    post {
        always {
            // Archive the security scan results
            archiveArtifacts artifacts: 'trufflehog-results.json,trivy-vuln.json,trivy-config.json', allowEmptyArchive: true
            cleanWs()
        }
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
        unstable {
            echo 'Pipeline completed with warnings (security issues found)!'
        }
    }
} 