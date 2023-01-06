pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = 'ap-northeast-2'

        VERSION             = 'v0.1.0'

        DOCKER_IMAGE        = 'test'
        DOCKER_TAG          = "${VERSION}-ci.${GIT_COMMIT}"

        DOCKER_IMAGE_REPO   = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}"
    }

    stages{
        stage('Versioning') {
            steps {
                script {
                    sh "printenv"
                    // env.VERSION_TAG = sh("git tag --list '^v(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$' | tail -n 1")
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