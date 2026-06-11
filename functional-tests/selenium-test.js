const { Builder, By, until } = require('selenium-webdriver');
const chrome = require('selenium-webdriver/chrome');
const chromedriver = require('chromedriver');
const os = require('os');
const path = require('path');

const APP_URL =
  process.env.APP_URL ||
  'http://localhost:8081/AlexanderMorozov_RoeiShalom_YaronMiroluz_DevOpsProject/';

async function runTests() {
  const options = new chrome.Options();

  const tempChromeProfile = path.join(os.tmpdir(), 'selenium-chrome-profile-' + Date.now());

  options.setChromeBinaryPath('C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe');

  options.addArguments(
    '--headless',
    '--disable-gpu',
    '--disable-software-rasterizer',
    '--no-sandbox',
    '--disable-dev-shm-usage',
    '--disable-extensions',
    '--disable-background-networking',
    '--no-first-run',
    '--no-default-browser-check',
    '--remote-allow-origins=*',
    `--user-data-dir=${tempChromeProfile}`
  );

  const service = new chrome.ServiceBuilder(chromedriver.path);

  console.log('Using app URL:', APP_URL);
  console.log('Using ChromeDriver:', chromedriver.path);

  const driver = await new Builder()
    .forBrowser('chrome')
    .setChromeOptions(options)
    .setChromeService(service)
    .build();

  try {
    await driver.get(APP_URL);

    const title = await driver.getTitle();
    if (!title.includes('MeTA DevOps Final Project')) {
      throw new Error('Validation failed: page title is incorrect. Actual title: ' + title);
    }
    console.log('PASS 1: Page title is correct');

    await driver.wait(until.elementLocated(By.id('main-title')), 10000);
    console.log('PASS 2: Main title exists');

    await driver.wait(until.elementLocated(By.id('maven-link')), 10000);
    console.log('PASS 3: External link exists');

    const input = await driver.wait(until.elementLocated(By.id('nameInput')), 10000);
    console.log('PASS 4: Input box exists');

    await input.clear();
    await input.sendKeys('Alexander');

    const button = await driver.wait(until.elementLocated(By.id('submitBtn')), 10000);
    await button.click();

    const greeting = await driver.wait(until.elementLocated(By.id('greetingResult')), 10000);
    const greetingText = await greeting.getText();

    if (!greetingText.includes('Hello, Alexander')) {
      throw new Error('Validation failed: greeting text is incorrect. Actual text: ' + greetingText);
    }

    console.log('PASS 5: Greeting appears after submitting name');
    console.log('All Selenium functional tests passed successfully.');
  } finally {
    await driver.quit();
  }
}

runTests().catch((error) => {
  console.error('Selenium functional test failed:');
  console.error(error);
  process.exit(1);
});