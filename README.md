# MeTA DevOps Final Project
**Students:** Alexander Morozov, Roei Shalom, and Yaron Miroluz 
**Course:** DevOps Engineering  
**Company:** MeTA Corporation

---

## Table of Contents
1. [What This Project Is](#1-what-this-project-is)
2. [Folder & File Explanation](#2-folder--file-explanation)
3. [Prerequisites](#3-prerequisites)
4. [How to Build Locally with Maven](#4-how-to-build-locally-with-maven)
5. [How to Run the App on Tomcat](#5-how-to-run-the-app-on-tomcat)
6. [How to Push Code to GitHub](#6-how-to-push-code-to-github)
7. [How to Create the Jenkins Pipeline](#7-how-to-create-the-jenkins-pipeline)
8. [Jenkins Plugins and Tools Needed](#8-jenkins-plugins-and-tools-needed)
9. [Configure Tomcat Path and App URL in Jenkinsfile](#9-configure-tomcat-path-and-app-url-in-jenkinsfile)
10. [How to Run the Selenium Test](#10-how-to-run-the-selenium-test)
11. [How to Run the Gatling Tests](#11-how-to-run-the-gatling-tests)
12. [How to Set Up UptimeRobot (5-Minute Monitor)](#12-how-to-set-up-uptimerobot-5-minute-monitor)
13. [What to Submit for the Final Project](#13-what-to-submit-for-the-final-project)
14. [Values You Must Replace](#14-values-you-must-replace)

---

## 1. What This Project Is

This project demonstrates the full **DevOps software delivery lifecycle** for a simple web application.

**The application** is a JSP (JavaServer Pages) web app named `AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject`. It runs on Apache Tomcat and lets users type their name, click a button, and see a greeting — a simple but complete demo of a web interaction.

**The pipeline** (defined in `Jenkinsfile`) automates everything that happens from "code on GitHub" to "app running and verified in production":

| Stage | What it does |
|-------|-------------|
| 1. Checkout | Pulls the code from GitHub |
| 2. Build WAR | Compiles and packages the app with Maven |
| 3. Deploy | Copies the WAR file into Tomcat |
| 4. Restart Tomcat | Restarts Tomcat to apply the new deployment |
| 5. Availability Check | Verifies the app is live (HTTP 200) |
| 6. Selenium Tests | Runs 5 automated functional tests |
| 7. Gatling Max Limit | Finds the app's maximum traffic capacity |
| 8. Gatling Load Test | 5-minute stable load test |
| 9. Gatling Stress Test | 5-minute escalating stress test |
| 10. Archive | Saves the WAR and reports as artifacts |

---

## 2. Folder & File Explanation

```
meta-devops-final-project/
│
├── pom.xml                          Maven project file — defines dependencies, build settings,
│                                    WAR name (AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject), and Gatling plugin
│
├── Jenkinsfile                      Jenkins pipeline script — defines all 10 pipeline stages
│
├── README.md                        This file
│
├── .gitignore                       Tells Git which files NOT to track (build output, IDE files)
│
├── src/
│   ├── main/
│   │   └── webapp/
│   │       ├── index.jsp            The web page — HTML + CSS + JSP logic
│   │       │                        Shows the name form; displays the greeting after submit
│   │       └── WEB-INF/
│   │           └── web.xml          Servlet configuration — sets index.jsp as the welcome file
│   │
│   └── test/
│       └── java/
│           └── meta/
│               └── performance/
│                   ├── MaxLimitSimulation.java   Gatling test — ramps to 200 users/sec to find limit
│                   ├── LoadSimulation.java        Gatling test — 10 users/sec constant for 5 minutes
│                   └── StressSimulation.java      Gatling test — 5-wave escalating load for 5 minutes
│
└── selenium/
    └── meta-app.side                Selenium IDE test file — 5 automated functional validations
```

---

## 3. Prerequisites

Install these tools before you begin. Each tool is linked to its download page.

| Tool | Version | Purpose |
|------|---------|---------|
| Java JDK | 11 or 17 | Required to build and run everything |
| Apache Maven | 3.8+ | Builds the WAR file, runs Gatling tests |
| Apache Tomcat | 9.x | Runs the web application |
| Jenkins | 2.387+ | Automates the pipeline |
| Node.js | 16+ | Required to run selenium-side-runner |
| Google Chrome | Latest | Required for Selenium headless tests |
| ChromeDriver | Same version as Chrome | Selenium browser driver |
| Git | Any | Version control |

**Check if Java and Maven are installed:**
```bash
java -version
mvn -version
```

Both must work before continuing.

---

## 4. How to Build Locally with Maven

This builds the `.war` file on your computer without needing Jenkins.

**Step 1 — Open a terminal/command prompt and navigate to the project folder:**
```bash
cd C:\Users\sasha\Desktop\College\DevOps\meta-devops-final-project
```
*(Adjust path if yours is different)*

**Step 2 — Build the WAR file:**
```bash
mvn clean package -DskipTests
```

**What happens:**
- Maven downloads all dependencies (first time only — takes a few minutes)
- Compiles the project
- Creates: `target/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject.war`

**To verify the build succeeded:**
```bash
dir target\AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject.war
```
You should see the WAR file listed with a size greater than 0 bytes.

---

## 5. How to Run the App on Tomcat

**Step 1 — Copy the WAR file to Tomcat webapps:**

On Linux:
```bash
cp target/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject.war /opt/tomcat/webapps/
```

On Windows (example):
```cmd
copy target\AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject.war C:\tomcat\webapps\
```

**Step 2 — Start (or restart) Tomcat:**

On Linux:
```bash
/opt/tomcat/bin/startup.sh
```

On Windows:
```cmd
C:\tomcat\bin\startup.bat
```

**Step 3 — Wait ~15 seconds, then open the app in your browser:**
```
http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject/
```

You should see the MeTA DevOps project page.  
Type your name in the input box, click **Run Pipeline**, and verify the greeting appears.

**To stop Tomcat:**
```bash
/opt/tomcat/bin/shutdown.sh      # Linux
C:\tomcat\bin\shutdown.bat       # Windows
```

---

## 6. How to Push Code to GitHub

**Step 1 — Create a new repository on GitHub:**
1. Go to https://github.com
2. Click the **+** icon → **New repository**
3. Name it: `meta-devops-final-project`
4. Set it to **Public** (so Jenkins can clone it without credentials)
5. Do NOT check "Add README" — you already have one
6. Click **Create repository**

**Step 2 — Initialize Git and push the project:**

Open a terminal in the project folder:
```bash
git init
git add .
git commit -m "Initial commit: MeTA DevOps Final Project"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/meta-devops-final-project.git
git push -u origin main
```

> **REPLACE:** Change `YOUR_GITHUB_USERNAME` to your actual GitHub username.

**Step 3 — Verify:** Refresh your GitHub repository page. All project files should appear there.

---

## 7. How to Create the Jenkins Pipeline

**Step 1 — Open Jenkins in your browser:**
```
http://localhost:8080
```
*(or wherever Jenkins is installed)*

**Step 2 — Create a new job:**
1. Click **New Item** (top left)
2. Enter name: `MeTA-DevOps-Pipeline`
3. Select **Pipeline**
4. Click **OK**

**Step 3 — Configure the pipeline:**
1. Scroll down to the **Pipeline** section
2. Under **Definition**, select **Pipeline script from SCM**
3. Under **SCM**, select **Git**
4. In **Repository URL**, paste your GitHub URL:
   ```
   https://github.com/YOUR_GITHUB_USERNAME/meta-devops-final-project.git
   ```
5. Under **Branch Specifier**, type: `*/main`
6. Under **Script Path**, type: `Jenkinsfile`
7. Click **Save**

**Step 4 — Run the pipeline:**
1. Click **Build Now** (left sidebar)
2. Click the build number that appears (e.g., `#1`)
3. Click **Console Output** to watch the pipeline run in real time

---

## 8. Jenkins Plugins and Tools Needed

### Required Jenkins Plugins
Install these from **Manage Jenkins → Plugins → Available plugins**:

| Plugin | Why it is needed |
|--------|-----------------|
| **Git Plugin** | Allows Jenkins to clone from GitHub |
| **Pipeline** | Enables Declarative Pipeline (Jenkinsfile) |
| **Pipeline: Stage View** | Shows the visual pipeline stages in Jenkins UI |
| **Workspace Cleanup** | (Optional) Cleans workspace between builds |

### Tools That Must Be on the Jenkins Server

| Tool | How to verify it is installed |
|------|------------------------------|
| Java 11+ | `java -version` in Jenkins terminal |
| Maven 3.8+ | `mvn -version` |
| Node.js 16+ | `node -version` |
| selenium-side-runner | `selenium-side-runner --version` |
| Google Chrome | `google-chrome --version` |
| ChromeDriver | `chromedriver --version` |

### Configure Maven in Jenkins
1. Go to **Manage Jenkins → Tools**
2. Under **Maven installations**, click **Add Maven**
3. Name it `Maven` and check **Install automatically** (or point to your Maven path)
4. Click **Save**

---

## 9. Configure Tomcat Path and App URL in Jenkinsfile

Open `Jenkinsfile` and find the `environment { }` section near the top.  
These are the values you **must** change:

```groovy
environment {
    // REPLACE with your actual Tomcat folder
    TOMCAT_HOME    = '/opt/tomcat'

    // This is built automatically from TOMCAT_HOME — usually no change needed
    TOMCAT_WEBAPPS = "${TOMCAT_HOME}/webapps"

    // The app name — must match the WAR file name (no .war extension)
    APP_NAME       = 'AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject'

    // REPLACE localhost with your server's public IP for internet access
    // Example: APP_URL = 'http://203.0.113.42:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject'
    APP_URL        = "http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject"

    // REPLACE with your GitHub repository clone URL
    GITHUB_REPO    = 'https://github.com/YOUR_GITHUB_USERNAME/meta-devops-final-project.git'
}
```

**For public IP (Bonus requirement):**  
Only change `APP_URL`. Everything else stays the same. The Gatling simulations automatically use `APP_URL` because they read the `app.base.url` Maven property which the Jenkinsfile passes as `-Dapp.base.url=${APP_URL}`.

---

## 10. How to Run the Selenium Test

The Selenium tests are defined in `selenium/meta-app.side`. There are two ways to run them.

### Option A — Run inside Jenkins (Automated)
The Jenkinsfile Stage 6 runs this automatically every time the pipeline executes.  
Requires `selenium-side-runner` to be installed on the Jenkins server:
```bash
npm install -g selenium-side-runner
```

### Option B — Run manually from the terminal
```bash
# Install selenium-side-runner globally (one-time)
npm install -g selenium-side-runner

# Run all 5 tests against the live app
selenium-side-runner \
  --base-url http://localhost:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject \
  -c "browserName=chrome goog:chromeOptions.args=[--headless,--no-sandbox]" \
  selenium/meta-app.side
```

### Option C — Open in Selenium IDE browser extension (Manual/Visual)
1. Install the **Selenium IDE** extension in Chrome or Firefox
2. Open Selenium IDE from the browser toolbar
3. Click **Open an existing project**
4. Select `selenium/meta-app.side`
5. Click the **Run all tests** button (▶▶)

### The 5 Test Validations
| Test | What it checks |
|------|---------------|
| Test 01 | Page loads successfully (title = "MeTA DevOps Final Project") |
| Test 02 | Main title H1 element exists and contains "MeTA DevOps" |
| Test 03 | External link elements exist on the page |
| Test 04 | Name input box and submit button exist |
| Test 05 | Typing "Alex" + clicking button → greeting "Hello, Alex" appears |

---

## 11. How to Run the Gatling Tests

**Before running Gatling**, the application must be deployed and running on Tomcat.

### Run from the terminal

Navigate to the project folder:
```bash
cd C:\Users\sasha\Desktop\College\DevOps\meta-devops-final-project
```

**Max Limit Test** (ramps to 200 users/sec to find the breaking point):
```bash
mvn gatling:test -Dgatling.simulationClass=meta.performance.MaxLimitSimulation
```

**Load Test** (10 users/sec for 5 minutes):
```bash
mvn gatling:test -Dgatling.simulationClass=meta.performance.LoadSimulation
```

**Stress Test** (escalating waves up to 120 users/sec):
```bash
mvn gatling:test -Dgatling.simulationClass=meta.performance.StressSimulation
```

**With a custom app URL:**
```bash
mvn gatling:test \
  -Dgatling.simulationClass=meta.performance.LoadSimulation \
  -Dapp.base.url=http://YOUR_PUBLIC_IP:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject
```

### Viewing the Reports

After each Gatling run, an HTML report is created in:
```
target/gatling/loadsimulation-<timestamp>/index.html
target/gatling/stresssimulation-<timestamp>/index.html
target/gatling/maxlimitsimulation-<timestamp>/index.html
```

Open the `index.html` file in your browser to see:
- Total requests made
- Response time percentiles (50th, 75th, 95th, 99th)
- Error percentage
- Throughput graph
- Response time distribution

### Understanding the Three Tests

**MaxLimitSimulation**  
Traffic ramps from 1 to 200 users/sec over 5 minutes.  
Look at the graph: when the response time starts climbing sharply or the error rate exceeds 5%, that traffic level is your app's practical limit.

**LoadSimulation**  
A constant 10 users/sec for 5 minutes after a 30-second warm-up.  
This simulates normal daily traffic. If the app fails this test, it is not production-ready.

**StressSimulation**  
Five waves of increasing traffic, peaking at 120 users/sec.  
This reveals how the app behaves under pressure — does it slow down gracefully, or does it crash?

---

## 12. How to Set Up UptimeRobot (5-Minute Monitor)

UptimeRobot is a free external monitoring service that checks your app every 5 minutes from around the world and alerts you by email if it goes down.

> **Note:** This only works if your app is accessible from the public internet (needs a public IP or a tunnel like ngrok).

**Step-by-step:**

1. Go to https://uptimerobot.com and click **Register for FREE**

2. Create a free account and verify your email

3. After logging in, click **+ Add New Monitor**

4. Fill in the form:
   - **Monitor Type:** `HTTP(s)`
   - **Friendly Name:** `MeTA DevOps App — Alexander Morozov • Roei Shalom • Yaron Miroluz`
   - **URL:** `http://YOUR_PUBLIC_IP:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject/`  
     *(Replace `YOUR_PUBLIC_IP` with your server's actual IP address)*
   - **Monitoring Interval:** `5 minutes`

5. Under **Alert Contacts**, click **Add Alert Contact** and add your email

6. Click **Create Monitor**

7. Wait a few minutes — UptimeRobot will show **UP** with a green checkmark if your app responds

**Screenshot to take:** The UptimeRobot dashboard showing your monitor with green **UP** status.

---

## 13. What to Submit for the Final Project

Take these screenshots and save them with clear filenames:

| # | What to screenshot | Suggested filename |
|---|-------------------|--------------------|
| 1 | Jenkins pipeline — all 10 stages green | `jenkins-pipeline-success.png` |
| 2 | Jenkins Stage 5 log showing "HTTP 200" availability check | `jenkins-availability-check.png` |
| 3 | The deployed app in browser (with the greeting visible) | `app-running-browser.png` |
| 4 | Jenkins Stage 6 log showing Selenium tests passed | `selenium-tests-passed.png` |
| 5 | Gatling Max Limit HTML report (index.html) | `gatling-maxlimit-report.png` |
| 6 | Gatling Load Test HTML report | `gatling-load-report.png` |
| 7 | Gatling Stress Test HTML report | `gatling-stress-report.png` |
| 8 | UptimeRobot dashboard showing your monitor | `uptimerobot-monitor.png` |
| 9 | Your GitHub repository with all files visible | `github-repo.png` |

**Also submit:**
- Your GitHub repository URL
- This project's folder zipped (including `target/gatling/` report folders)

---

## 14. Values You Must Replace

These are the only values you need to change before the pipeline works.  
Everything else is pre-configured.

| File | Variable / Location | What to replace | Example |
|------|---------------------|----------------|---------|
| `Jenkinsfile` | `TOMCAT_HOME` | Path to your Tomcat installation | `/opt/tomcat` or `C:/tomcat` |
| `Jenkinsfile` | `GITHUB_REPO` | Your GitHub repository URL | `https://github.com/alex123/meta-devops-final-project.git` |
| `Jenkinsfile` | `APP_URL` | Change `localhost` to public IP (optional, for bonus) | `http://203.0.113.42:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject` |
| `src/main/webapp/index.jsp` | GitHub link `href` | Your GitHub repo URL | `https://github.com/AlexMorozov324/meta-devops-final-project` |
| `selenium/meta-app.side` | `"url"` field | Your app URL if not localhost | `http://YOUR_IP:8080/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject` |

---

*Built with Maven · Deployed on Apache Tomcat · CI/CD via Jenkins · Functional tests: Selenium · Performance tests: Gatling*
