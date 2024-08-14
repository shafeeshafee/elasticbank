pipeline {
    agent any
    options {
        timeout(time: 10, unit: 'MINUTES')
        disableConcurrentBuilds()  // prevents concurrent builds of the same job
        buildDiscarder(logRotator(numToKeepStr: '5'))  // keep only the last 5 builds
    }
    stages {
        stage ('Build') {
            steps {
                sh '''#!/bin/bash
                python3.7 -m venv venv
                source venv/bin/activate
                pip install pip --upgrade
                pip install -r requirements.txt
                '''
            }
        }
        stage ('Test') {
            steps {
                script {
                    def attempts = 3
                    def interval = 60  // seconds
                    while (attempts > 0) {
                        try {
                            sh '''#!/bin/bash
                            chmod +x system_resources_test.sh
                            ./system_resources_test.sh
                            '''
                            break  // If successful, exit the loop
                        } catch (Exception e) {
                            attempts--
                            if (attempts == 0) {
                                error "Resource test failed after 3 attempts"
                            }
                            echo "Test failed. Retrying in 60 seconds..."
                            sleep interval
                        }
                    }
                }
            }
        }
        stage ('Deploy') {
            steps {
                sh '''#!/bin/bash
                source venv/bin/activate
                eb create elasticbank --single
                '''
            }
        }
    }
}
