pipeline {
    agent any

    stages {

        stage("Checkout source") {
            steps {
                git url: 'https://github.com/JoabsonB/Jenkins-Ec2.git', branch: 'main'
                sh 'ls'
            }
        }
    }
}