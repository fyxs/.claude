/**
 * 连接到通过 start-edge-debug.bat 启动的 Edge 浏览器
 * 端口：9222
 */

const { chromium } = require('playwright');

async function connectToEdge() {
  try {
    console.log('正在连接到 Edge (端口 9222)...');

    // 连接到调试端口
    const browser = await chromium.connectOverCDP('http://localhost:9222');
    console.log('✓ 已连接到 Edge');

    // 获取现有上下文和页面
    const contexts = browser.contexts();
    const context = contexts[0];
    const pages = context.pages();

    console.log(`当前有 ${pages.length} 个标签页`);

    // 使用现有标签页或创建新标签页
    let page;
    if (pages.length > 0) {
      page = pages[0];
      console.log('使用现有标签页');
    } else {
      page = await context.newPage();
      console.log('创建新标签页');
    }

    // 示例操作：访问网站
    console.log('\n访问 example.com...');
    await page.goto('https://example.com');

    const title = await page.title();
    console.log(`页面标题: ${title}`);

    // 截图
    await page.screenshot({ path: 'edge-screenshot.png' });
    console.log('✓ 截图已保存');

    console.log('\n连接保持中，按 Ctrl+C 退出');
    // 不关闭浏览器，保持连接

  } catch (error) {
    console.error('连接失败:', error.message);
    console.log('\n请确保：');
    console.log('1. 已运行 start-edge-debug.bat');
    console.log('2. Edge 浏览器正在运行');
  }
}

connectToEdge();
