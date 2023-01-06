pipeline {
    agent {
        label 'ec2_agent_node'
    }

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = 'ap-northeast-2'
        DOCKER_IMAGE_REPO   = 'test'
        ECR_REGISTRY        = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE_REPO}"
        TAG                 = "${BRANCH_NAME.replace("release/","")}-${GIT_COMMIT}"
    }

    stages{
        stage('Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE_REPO} ."
                sh "docker tag ${DOCKER_IMAGE_REPO} ${ECR_REGISTRY}:${TAG}"
            }
        }

        stage('Deploy Beta') {
            when {
                branch "release/beta"
            }

            steps {
                echo "Deploying beta..."
            }
        }
    }
}