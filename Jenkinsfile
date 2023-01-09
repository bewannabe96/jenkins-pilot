pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = 742627718059

        ECR_REGION          = "us-east-1"
        DOCKER_IMAGE_REPO   = "ourspaceapp/daytrip-web"
        DOCKER_IMAGE_URI    = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE_REPO}"
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
                    def parts = sh(
                        returnStdout: true,
                        script: 'git tag --sort=-v:refname --list | grep -E \'^v(0|[0-9]+)\\.(0|[0-9]+)\\.(0|[0-9]+)\$\' | head -n 1'
                    ).trim().substring(1).tokenize('.')

                    def major = parts[0].toInteger()
                    def minor = parts[1].toInteger()
                    def patch = parts[2].toInteger()

                    if (env.BRANCH_NAME == 'develop') {
                        minor = minor + 1
                        patch = 0
                    } else {
                        patch = patch + 1
                    }

                    env.VERSION = "${major}.${minor}.${patch}"
                }
            }
        }

        stage('Integrate') {
            steps {
                script {
                    def hash = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()

                    if (env.BRANCH_NAME == 'develop') {
                        env.TAG = "${VERSION}-ci.${hash}"
                    } else {
                        env.TAG = "${VERSION}-qfe.${hash}"
                    }

                    env.GIT_TAG = "v${TAG}"
                }

                sh "git tag ${GIT_TAG}"
                sh "git push origin ${GIT_TAG}"
            }

        }

        stage('Build') {
            steps {
                script {
                    env.DOCKER_TAG = "${TAG}"
                }

                sh "docker build -t ${DOCKER_IMAGE_REPO} ."
                sh "docker tag ${DOCKER_IMAGE_REPO} ${DOCKER_IMAGE_URI}:${DOCKER_TAG}"
                sh "docker push ${DOCKER_IMAGE_URI}:${DOCKER_TAG}"
            }
        }

        stage('Test') {
            steps {
                echo "Testing..."
            }
        }

        stage('Stage') {
            when {
                branch 'develop'
            }

            steps {
                sh "git checkout release"
                sh "git merge --no-ff ${GIT_TAG} -m 'STAGED'"
                sh "git push origin release"

                script {
                    def hash = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()

                    env.TAG = "${VERSION}-rc.${hash}"
                    env.GIT_TAG = "v${TAG}"
                }

                sh "git tag ${GIT_TAG}"
                sh "git push origin ${GIT_TAG}"

                sh "docker tag ${DOCKER_IMAGE_URI}:${DOCKER_TAG} ${DOCKER_IMAGE_URI}:stage"
                sh "docker push ${DOCKER_IMAGE_URI}:stage"

                echo "TODO:Deploy"
            }
        }

        stage('Approve') {
            steps {
                input message: "Do you want to release ${TAG}?", ok: "Release"
            }
        }

        stage('Release') {
            steps {
                sh "git checkout master"
                sh "git merge --no-ff ${GIT_TAG} -m 'RELEASE'"
                sh "git push origin master"

                script {
                    env.TAG = "${VERSION}"
                    env.GIT_TAG = "v${TAG}"
                }

                sh "git tag ${GIT_TAG}"
                sh "git push origin ${GIT_TAG}"

                sh "docker tag ${DOCKER_IMAGE_URI}:${DOCKER_TAG} ${DOCKER_IMAGE_URI}:latest"
                sh "docker push ${DOCKER_IMAGE_URI}:latest"
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying beta..."
            }
        }
    }
}