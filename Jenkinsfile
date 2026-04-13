pipeline {
    agent any
    environment {
        EC2_USER = "ubuntu"
        EC2_HOST = "18.209.240.168"
        EC2_KEY = credentials('ec2-ssh-private-key')
        PROJECT_DIR = "/home/ubuntu/pythonprojects/App1"
    }
    triggers {
        githubPush()
    }
    stages {
        stage('Update Code on EC2') {
            steps {
                script {
                    sshagent (credentials: ['ec2-ssh-private-key']) {
                        sh """
                        ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} '
                            cd ${PROJECT_DIR}
                            git pull origin main
                            python3 -m venv comp314
                            source comp314/bin/activate
                            python3 -m pip install -r requirements.txt
                            python3 manage.py migrate --noinput
                            python3 manage.py runserver 0.0.0.0:8000 &
                        '
                        """
                    }
                }
            }
        }
    }
    post {
        success {
            echo "Code updated and app restarted successfully on EC2!"
        }
        failure {
            echo "Deployment failed."
        }
    }
}