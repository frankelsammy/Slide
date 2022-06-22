pipeline {
    agent any
    environment {
        NEW_VERSON = '1.3.0'
    }
    stages {
        stage("build") {
            steps{
                echo 'building the app'
                echo "buidling verson ${NEW_VERSION}"
            }
        }
        stage("test") {

            steps{
                echo 'testing the app'
            }
        }
    
    }

}
