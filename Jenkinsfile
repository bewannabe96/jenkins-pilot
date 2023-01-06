pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = 'ap-northeast-2'
        DOCKER_IMAGE        = "test"
    }

    stages{
        stage('Version') {
            steps {
                script {
                    env.VERSION = sh(
                        returnStdout: true,
                        script: 'git fetch --all --tags | git tag --sort=-v:refname --list | grep -E \'^v(0|[0-9]+)\\.(0|[0-9]+)\\.(0|[0-9]+)\$\' | head -n 1'
                    ).trim()
                }

                echo "${VERSION}"
            }
        }

        stage('Build') {
            steps {
                script {
                    env.DOCKER_TAG = "${VERSION}-ci.${GIT_COMMIT.substring(0,8)}"
                    env.DOCKER_IMAGE_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }

                sh "docker build -t ${DOCKER_IMAGE} ."
                sh "docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_REPO}"
            }
        }

        stage('Deploy (Beta)') {
            when {
                branch "release/beta"
            }

            steps {
                echo "Deploying beta..."
            }
        }
    }
}