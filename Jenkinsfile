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