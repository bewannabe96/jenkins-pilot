pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID      = 742627718059
        ECR_REGION          = "ap-northeast-2"
        DOCKER_IMAGE_REPO   = "test"
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
                    def hash = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()

                    if (env.BRANCH_NAME == 'develop') {
                        env.TAG = "v${LATEST_VERSION}-ci.${hash}"
                    } else {
                        env.TAG = "v${LATEST_VERSION}-qfe.${hash}"
                    }
                }

                sh "git tag ${TAG}"
                sh "git push origin ${TAG}"
            }

        }

        stage('Build') {
            steps {
                script {
                    env.DOCKER_TAG = "${TAG}"
                    env.DOCKER_IMAGE_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${ECR_REGION}.amazonaws.com/${DOCKER_IMAGE_REPO}:${DOCKER_TAG}"
                }

                // sh "docker build -t ${DOCKER_IMAGE_REPO} ."
                // sh "docker tag ${DOCKER_IMAGE_REPO} ${DOCKER_IMAGE_URI}"
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
                script {
                    sh "git checkout release"
                    sh "git merge --no-ff ${TAG} -m 'STAGED'"
                    sh "git push origin release"
                }

                script {
                    def hash = sh(
                        returnStdout: true,
                        script: 'git rev-parse --short HEAD'
                    ).trim()

                    env.TAG = "v${LATEST_VERSION}-rc.${hash}"
                }

                sh "git tag ${TAG}"
                sh "git push origin ${TAG}"

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
                sh "git merge --no-ff ${TAG} -m 'RELEASE'"
                sh "git push origin master"

                sh "git tag v${RELEASE_VERSION}"
                sh "git push origin v${RELEASE_VERSION}"
            }
        }

        stage('Deploy') {
            steps {
                echo "Deploying beta..."
            }
        }
    }
}