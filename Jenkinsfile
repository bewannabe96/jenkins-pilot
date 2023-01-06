pipeline {
    agent {
        label 'ec2_agent_node'
    }

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = 'ap-northeast-2'

        DOCKER_IMAGE        = 'test'
        DOCKER_TAG          = "${BRANCH_NAME.replace("release/","")}-${GIT_COMMIT}"

        DOCKER_IMAGE_REPO   = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}"
    }

    stages{
        stage('Versioning') {
            steps {
                script {
                    env.VERSION_TAG = sh("git describe --tags --abbrev=0 master")
                }
                echo "${VERSION_TAG}"
            }
        }

        stage('Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE} ."
                sh "docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_REPO}"
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