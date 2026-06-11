pipeline {
    agent any

    environment {
        TOMCAT_HOME = 'C:/tomcat'
        TOMCAT_WEBAPPS = 'C:/tomcat/webapps'

        APP_NAME = 'AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject'
        APP_URL = 'http://localhost:8081/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject'

        GITHUB_REPO = 'https://github.com/AlexMorozov324/meta-devops-final-project.git'
        MVN = 'mvn'
    }

    stages {
        stage('1. Checkout from GitHub') {
            steps {
                echo 'Checking out code from GitHub'
                git url: "${GITHUB_REPO}", branch: 'main'
            }
        }

        stage('2. Build WAR with Maven') {
            steps {
                echo 'Building WAR file'
                bat "${MVN} clean package -DskipTests"
                bat "dir target"
            }
        }

        stage('3. Deploy WAR to Tomcat') {
            steps {
                echo 'Deploying WAR to Tomcat webapps folder'

                bat """
                if exist "%TOMCAT_WEBAPPS%\\%APP_NAME%" rmdir /S /Q "%TOMCAT_WEBAPPS%\\%APP_NAME%"
                if exist "%TOMCAT_WEBAPPS%\\%APP_NAME%.war" del /Q "%TOMCAT_WEBAPPS%\\%APP_NAME%.war"
                copy /Y "target\\%APP_NAME%.war" "%TOMCAT_WEBAPPS%\\"
                """
            }
        }

        stage('4. Wait for Tomcat Auto-Deploy') {
            steps {
                echo 'Tomcat is already running. Waiting for WAR auto-deployment.'

                bat """
                echo Waiting for Tomcat to auto-deploy the WAR file...
                powershell -Command "Start-Sleep -Seconds 30"
                dir "%TOMCAT_WEBAPPS%"
                """
            }
        }

        stage('5. Availability Check') {
            steps {
                echo 'Checking if application is available'
                bat """
                echo Checking application URL: %APP_URL%/

                curl.exe -f "%APP_URL%/"

                if errorlevel 1 (
                     echo Application is still not available.
                     echo Showing Tomcat webapps folder:
                     dir "%TOMCAT_WEBAPPS%"
                     exit /b 1
                )

                echo Application is available.
                """
            }
        }

        stage('6. Selenium Functional Tests') {
            steps {
                echo 'Running Selenium WebDriver functional tests'

                bat """
                set "PATH=C:\\Program Files\\Google\\Chrome\\Application;C:\\nvm4w\\nodejs;%PATH%"
                set "APP_URL=%APP_URL%/"

                echo Checking Node, npm and Chrome...
                where node
                where npm
                where chrome.exe

                echo Installing Node dependencies...
                call npm.cmd install

                echo Running Selenium WebDriver tests...
                call npm.cmd run selenium:test
                """
            }
        }

        stage('7. Gatling - Max Limit Test') {
            steps {
                echo 'Running Gatling max limit test'
                bat "${MVN} gatling:test -Dgatling.simulationClass=meta.performance.MaxLimitSimulation -Dapp.base.url=${APP_URL}"
            }
        }

        stage('8. Gatling - 5-Minute Load Test') {
            steps {
                echo 'Running Gatling 5-minute load test'
                bat "${MVN} gatling:test -Dgatling.simulationClass=meta.performance.LoadSimulation -Dapp.base.url=${APP_URL}"
            }
        }

        stage('9. Gatling - 5-Minute Stress Test') {
            steps {
                echo 'Running Gatling 5-minute stress test'
                bat "${MVN} gatling:test -Dgatling.simulationClass=meta.performance.StressSimulation -Dapp.base.url=${APP_URL}"
            }
        }

        stage('10. Archive Artifacts') {
            steps {
                echo 'Archiving WAR and Gatling reports'

                archiveArtifacts artifacts: 'target/*.war',
                                 fingerprint: true,
                                 allowEmptyArchive: true

                archiveArtifacts artifacts: 'target/gatling/**',
                                 allowEmptyArchive: true
            }
        }
    }

    post {
        success {
            echo """
            ============================================================
            PIPELINE COMPLETED SUCCESSFULLY

            Application URL:
            ${APP_URL}

            WAR file:
            target/${APP_NAME}.war

            Gatling reports:
            target/gatling/
            ============================================================
            """
        }

        failure {
            echo """
            ============================================================
            PIPELINE FAILED

            Check the failed Jenkins stage.
            ============================================================
            """
        }
    }
}