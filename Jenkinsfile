pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = 'ap-northeast-2'

        VERSION             = "${sh(returnStdout:true,script:'git tag --sort=-v:refname --list | grep -E \'^v(0|[0-9]+)\\.(0|[0-9]+)\\.(0|[0-9]+)$\' | head -n 1')}"

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
                echo "${VERSION}"
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