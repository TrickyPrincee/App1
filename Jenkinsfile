pipeline {
    agent any
    options {
    buildDiscarder(logRotator(numToKeepStr: '3'))
}
    environment {
        DOCKER_IMAGE = 'princeoby/pollsapp'
        EC2_USER = "ubuntu"
        EC2_HOST = "100.53.239.168" // Update EC2 IP Address Unless Elastic
        EC2_KEY = credentials('ec2-ssh-private-key')
        DOCKER_CREDS = 'efed61b0-6b31-46d8-b64a-249f9df26930'
        PROJECT_DIR = "/home/ubuntu/pythonprojects/App1"
    }

    stages { 
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