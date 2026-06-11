pipeline {
    agent any

    environment {
        TOMCAT_HOME    = 'C:\tomcat'
        TOMCAT_WEBAPPS = "${TOMCAT_HOME}/webapps"

        // ── Application ───────────────────────────────────────────────────────
        APP_NAME       = 'AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject'
        APP_URL        = "http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject"

        // ── GitHub ────────────────────────────────────────────────────────────
        GITHUB_REPO    = 'https://github.com/AlexMorozov324/meta-devops-final-project.git'

        // ── Maven ─────────────────────────────────────────────────────────────
        // 'mvn' if Maven is on the system PATH, or the full path to the binary
        // Example full path: /usr/local/apache-maven-3.9.6/bin/mvn
        MVN            = 'mvn'
    }

    stages {
        stage('1. Checkout from GitHub') {
            steps {
                echo "========== STAGE 1: Checkout from GitHub =========="
                echo "Repository: ${GITHUB_REPO}"
                git url: "${GITHUB_REPO}", branch: 'main'
                echo "Checkout complete."
            }
        }

        stage('2. Build WAR with Maven') {
            steps {
                echo "========== STAGE 2: Build WAR with Maven =========="
                sh "${MVN} clean package -DskipTests"
                echo "Build complete."
                sh "ls -lh target/*.war"
            }
        }

        stage('3. Deploy WAR to Tomcat') {
            steps {
                echo "========== STAGE 3: Deploy WAR to Tomcat =========="
                echo "Deploying to: ${TOMCAT_WEBAPPS}"

                sh "rm -rf  '${TOMCAT_WEBAPPS}/${APP_NAME}'  || true"
                sh "rm -f   '${TOMCAT_WEBAPPS}/${APP_NAME}.war' || true"

                sh "cp 'target/${APP_NAME}.war' '${TOMCAT_WEBAPPS}/'"

                echo "WAR deployed: ${TOMCAT_WEBAPPS}/${APP_NAME}.war"
            }
        }

        stage('4. Restart Tomcat') {
            steps {
                echo "========== STAGE 4: Restart Tomcat =========="
                sh "${TOMCAT_HOME}/bin/shutdown.sh || true"

                sh 'sleep 8'

                sh "${TOMCAT_HOME}/bin/startup.sh"

                sh 'sleep 20'

                echo "Tomcat restarted."
            }
        }

        stage('5. Availability Check') {
            steps {
                echo "========== STAGE 5: Availability Check =========="
                echo "Checking: ${APP_URL}"

                retry(5) {
                    sleep(time: 10, unit: 'SECONDS')
                    sh """
                        HTTP_STATUS=\$(curl -s -o /dev/null -w "%{http_code}" "${APP_URL}/")
                        echo "HTTP response code: \$HTTP_STATUS"
                        if [ "\$HTTP_STATUS" != "200" ]; then
                            echo "FAIL: Expected 200 but got \$HTTP_STATUS"
                            exit 1
                        fi
                        echo "PASS: Application is available (HTTP 200)"
                    """
                }
            }
        }

        stage('6. Selenium Functional Tests') {
            steps {
                echo "========== STAGE 6: Selenium Functional Tests =========="

                sh """
                    selenium-side-runner \
                        --base-url "${APP_URL}" \
                        -c "browserName=chrome goog:chromeOptions.args=[--headless,--no-sandbox,--disable-dev-shm-usage,--disable-gpu]" \
                        selenium/meta-app.side
                """
            }
            post {
                failure {
                    echo "Selenium tests FAILED. Ensure ChromeDriver and selenium-side-runner are installed on this agent."
                }
            }
        }

        stage('7. Gatling - Max Limit Test') {
            steps {
                echo "========== STAGE 7: Gatling Max Limit Test =========="
                echo "Ramping from 1 to 200 users/sec over 5 minutes..."

                sh "${MVN} gatling:test -Dgatling.simulationClass=meta.performance.MaxLimitSimulation -Dapp.base.url=${APP_URL}"
            }
            post {
                always {
                    echo "Max Limit test complete. HTML report: target/gatling/"
                }
            }
        }

        stage('8. Gatling - 5-Minute Load Test') {
            steps {
                echo "========== STAGE 8: Gatling 5-Minute Load Test =========="
                echo "Running 10 users/sec for 5 minutes..."

                sh "${MVN} gatling:test -Dgatling.simulationClass=meta.performance.LoadSimulation -Dapp.base.url=${APP_URL}"
            }
            post {
                always {
                    echo "Load test complete. HTML report: target/gatling/"
                }
            }
        }

        stage('9. Gatling - 5-Minute Stress Test') {
            steps {
                echo "========== STAGE 9: Gatling 5-Minute Stress Test =========="
                echo "Running escalating wave stress test (peaks at 120 users/sec)..."

                sh "${MVN} gatling:test -Dgatling.simulationClass=meta.performance.StressSimulation -Dapp.base.url=${APP_URL}"
            }
            post {
                always {
                    echo "Stress test complete. HTML report: target/gatling/"
                }
            }
        }

        stage('10. Archive Artifacts') {
            steps {
                echo "========== STAGE 10: Archiving Artifacts =========="

                archiveArtifacts artifacts: 'target/*.war',
                                 fingerprint: true,
                                 allowEmptyArchive: false

                archiveArtifacts artifacts: 'target/gatling/**',
                                 allowEmptyArchive: true

                echo "Artifacts archived successfully."
            }
        }

    } 

    post {
        success {
            echo """
            ============================================================
              PIPELINE COMPLETED SUCCESSFULLY
              App URL  : ${APP_URL}
              WAR File : target/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject.war
              Reports  : target/gatling/
            ============================================================
            """
        }

        failure {
            echo """
            ============================================================
              PIPELINE FAILED
              Review the red stage above to identify the issue.
              Common causes:
                - Wrong TOMCAT_HOME path
                - Jenkins user lacks Tomcat write permission
                - Application not reachable (wrong APP_URL)
                - selenium-side-runner not installed
            ============================================================
            """
        }

        always {
            archiveArtifacts artifacts: 'target/*.war',          allowEmptyArchive: true
            archiveArtifacts artifacts: 'target/gatling/**',     allowEmptyArchive: true

            echo "Build #${BUILD_NUMBER} finished."
        }
    }

} 
