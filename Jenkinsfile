@Library('github.com/releaseworks/jenkinslib') _

pipeline {
    agent any
    environment {
        AWS_DEFAULT_REGION = 'eu-north-1'
    }
    stages {
        stage('Deploy') {
            steps {
                withCredentials([aws(credentialsId: 'aws-credentials-id')]) {
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}

// pipeline {
//     agent any
    
//     withCredentials([usernamePassword(credentialsId: 'aws_key', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
//         // available as an env variable, but will be masked if you try to print it out any which way
//         // note: single quotes prevent Groovy interpolation; expansion is by Bourne Shell, which is what you want
//         sh 'echo $PASSWORD'
//         // also available as a Groovy variable
//         echo USERNAME
//         // or inside double quotes for string interpolation
//         echo "username is $USERNAME"
//     }
    

    // environment {
    //     AWS_REGION = 'eu-north-1'
    //     EKS_CLUSTER = 'blog-cluster'
    //     ECR_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.us-east-1.amazonaws.com/blog-repo"
    // }
    
    // stages {
    //     stage('Build & Push') {
    //         steps {
    //             script {
    //                 sh '''
    //                 aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
    //                 docker build -t ${ECR_REPO}:${BUILD_NUMBER} .
    //                 docker push ${ECR_REPO}:${BUILD_NUMBER}
    //                 '''
    //             }
    //         }
    //     }
        
    //     stage('Deploy to EKS') {
    //         steps {
    //             script {
    //                 sh '''
    //                 aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
    //                 kubectl set image deployment/your-app your-app=${ECR_REPO}:${BUILD_NUMBER}
    //                 '''
    //             }
    //         }
    //     }
    // }
// }


