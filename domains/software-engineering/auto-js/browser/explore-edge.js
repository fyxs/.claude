/**
 * 探索当前 Edge 浏览器中的内容
 */

const { chromium } = require('playwright');

async function exploreEdge() {
  try {
    console.log('正在连接到 Edge...\n');

    const browser = await chromium.connectOverCDP('http://localhost:9222');
    const contexts = browser.contexts();

    console.log(`=== 浏览器信息 ===`);
    console.log(`浏览器上下文数量: ${contexts.length}\n`);

    for (let i = 0; i < contexts.length; i++) {
      const context = contexts[i];
      const pages = context.pages();

      console.log(`--- 上下文 ${i + 1} ---`);
      console.log(`标签页数量: ${pages.length}\n`);

      for (let j = 0; j < pages.length; j++) {
        const page = pages[j];

        try {
          const url = page.url();
          const title = await page.title();

          console.log(`[标签页 ${j + 1}]`);
          console.log(`  标题: ${title}`);
          console.log(`  URL: ${url}`);

          // 尝试获取页面主要内容
          try {
            const bodyText = await page.evaluate(() => {
              const body = document.body;
              return body ? body.innerText.substring(0, 500) : '无法获取内容';
            });
            console.log(`  内容预览: ${bodyText.substring(0, 200).replace(/\n/g, ' ')}...`);
          } catch (e) {
            console.log(`  内容预览: 无法访问页面内容`);
          }

          console.log('');
        } catch (error) {
          console.log(`[标签页 ${j + 1}] 无法访问: ${error.message}\n`);
        }
      }
    }

    console.log('=== 探索完成 ===');

    // 不关闭浏览器
    await browser.disconnect();

  } catch (error) {
    console.error('连接失败:', error.message);
    console.log('\n请确保 Edge 已通过 start-edge-debug.bat 启动');
  }
}

exploreEdge();
