pipeline {
    agent any
    environment {
        DOCKER_IMAGE = 'princeoby/pollsapp'
        EC2_USER = "ubuntu"
        EC2_HOST = "98.92.188.244"
        EC2_KEY = credentials('ec2-ssh-private-key')
        DOCKER_CREDS = 'docker-hub-credentials'
        PROJECT_DIR = "/home/ubuntu/pythonprojects/App1"
    }

        stages {
        stage('Clone Repository') {
            steps {
                // (MODIFY: Enter your GitHub repository URL)
                git branch: 'main', url: 'https://github.com/TrickyPrincee/App1.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:latest")
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', DOCKER_CREDS) {
                        docker.image("${DOCKER_IMAGE}:latest").push()
                        echo "Image pushed to Docker Hub"
                    }
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                script {
                    sshagent (credentials: ['ec2-ssh-private-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            docker pull ${DOCKER_IMAGE}:latest
                            docker ps -a -q -f name=django-container | grep -q . && docker stop django-container || true
                            docker ps -a -q -f name=django-container | grep -q . && docker rm django-container || true
                            docker run -d --name django-container -p 80:80 ${DOCKER_IMAGE}:latest
                            sleep 5
                            docker ps -a
                            docker logs django-container || true
                        '
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Deployment Successful!'
        }
        failure {
            echo 'Deployment Failed.'
        }
    }
}