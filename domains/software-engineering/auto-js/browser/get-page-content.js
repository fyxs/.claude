const { chromium } = require('playwright');

(async () => {
  try {
    const browser = await chromium.connectOverCDP('http://localhost:9222');
    const contexts = browser.contexts();
    const pages = await contexts[0].pages();

    // 获取当前活动页面
    const page = pages[pages.length - 1];

    const info = {
      title: await page.title(),
      url: page.url(),
      content: await page.content(),
      text: await page.innerText('body')
    };

    console.log(JSON.stringify(info, null, 2));

    await browser.close();
  } catch (error) {
    console.error('错误:', error.message);
  }
})();
