pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = "ap-northeast-2"
        DOCKER_IMAGE        = "test"
    }

    stages{
        stage('Checkout') {
            steps {
                sh "git fetch --all"
            }
        }

        stage('Version') {
            steps {
                script {
                    env.LATEST_VERSION = sh(
                        returnStdout: true,
                        script: 'git tag --sort=-v:refname --list | grep -E \'^v(0|[0-9]+)\\.(0|[0-9]+)\\.(0|[0-9]+)\$\' | head -n 1'
                    ).trim()

                    env.CI_SHORT_HASH = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()
                    env.CI_TAG = "${LATEST_VERSION}-ci.${CI_SHORT_HASH}"
                }

                sh "git tag ${CI_TAG}"
                sh "git push origin ${CI_TAG}"
            }
        }

        stage('Build') {
            steps {
                script {
                    env.DOCKER_TAG = "${CI_TAG}"
                    env.DOCKER_IMAGE_REPO = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE}:${DOCKER_TAG}"
                }

                // sh "docker build -t ${DOCKER_IMAGE} ."
                // sh "docker tag ${DOCKER_IMAGE} ${DOCKER_IMAGE_REPO}"
            }
        }

        stage('Test') {
            steps {
                echo "Testing..."
            }
        }

        stage('Deploy (Beta)') {
            when {
                branch "develop"
            }

            steps {
                echo "Deploying beta..."
            }
        }

        stage('Stage') {
            when {
                branch "develop"
            }

            steps {
                sh "git checkout release"
                sh "git merge --no-ff ${CI_TAG} -m 'STAGED'"
                sh "git push origin release"

                script {
                    env.RC_SHORT_HASH = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()
                    env.RC_TAG = "${LATEST_VERSION}-rc.${RC_SHORT_HASH}"
                }

                sh "git tag ${RC_TAG}"
                sh "git push origin ${RC_TAG}"
            }
        }

        stage('Release') {
            steps {
                input message: 'Do you want to release the latest stable build?', ok: 'Release'

                echo "Releasing..."
            }
        }
    }
}