pipeline {
    agent any
    
    environment {
        AWS_REGION = 'eu-north-1'
        EKS_CLUSTER = 'blog-cluster'
        ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/blog-repo"
    }
    
    stages {
        stage('Build & Push') {
            steps {
                script {
                    sh '''
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                    docker build -t ${ECR_REPO}:${BUILD_NUMBER} .
                    docker push ${ECR_REPO}:${BUILD_NUMBER}
                    '''
                }
            }
        }
        
        stage('Deploy to EKS') {
            steps {
                script {
                    sh '''
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                    kubectl set image deployment/your-app your-app=${ECR_REPO}:${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
}
