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
                    ).trim().substring(1)
                }
            }
        }

        stage('Integrate') {
            steps {
                script {
                    env.CI_SHORT_HASH = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()
                    env.CI_TAG = "v${LATEST_VERSION}-ci.${CI_SHORT_HASH}"
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

        stage('Stage') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'develop') {
                        sh "git checkout release"
                        sh "git merge --no-ff ${CI_TAG} -m 'STAGED'"
                        sh "git push origin release"
                    }
                }

                script {
                    env.RC_SHORT_HASH = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()
                    env.RC_TAG = "v${LATEST_VERSION}-rc.${RC_SHORT_HASH}"
                }

                sh "git tag ${RC_TAG}"
                sh "git push origin ${RC_TAG}"
            }
        }

        stage('Deploy - Beta') {
            when {
                branch 'develop'
            }

            steps {
                echo "TODO"
            }
        }

        stage('Approve') {
            steps {
                input message: "Do you want to release ${RC_TAG}?", ok: "Release"
            }
        }

        stage('Deploy - Prod') {
            steps {
                echo "Deploying beta..."
            }
        }

        stage('Release') {
            steps {
                script {
                    def parts = LATEST_VERSION.tokenize('.')

                    def major = parts[0].toInteger()
                    def minor = parts[1].toInteger()
                    def patch = parts[2].toInteger()

                    if (env.BRANCH_NAME == 'develop') {
                        env.MERGE_BRANCH = 'origin/release'
                        minor = minor + 1
                    } else {
                        env.MERGE_BRANCH = 'origin/hotfix'
                        patch = patch + 1
                    }

                    env.RELEASE_VERSION = "${major}.${minor}.${patch}"
                }

                sh "git checkout master"
                sh "git merge --no-ff ${MERGE_BRANCH} -m 'RELEASE'"
                sh "git push origin master"

                sh "git tag v${RELEASE_VERSION}"
                sh "git push origin v${RELEASE_VERSION}"
            }
        }
    }
}