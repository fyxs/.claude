#!/usr/bin/env node
/**
 * edge-cli - Edge 浏览器控制工具
 * 通过 CDP 协议连接和操作已运行的 Edge 浏览器
 * 使用 Puppeteer 实现
 */

const puppeteer = require('puppeteer-core');
const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs');
const path = require('path');
const http = require('http');
const execAsync = promisify(exec);

const CDP_PORT = 9222;
const CDP_URL = `http://127.0.0.1:${CDP_PORT}`;  // 使用 127.0.0.1 避免 IPv6 问题
const EDGE_SCRIPT = path.join(__dirname, 'start-edge-debug.bat');

// 命令帮助信息
const commands = {
  start: '启动 Edge 浏览器（如果未运行）',
  check: '检查 Edge 是否运行',
  diagnose: '诊断 Edge 连接问题',
  open: '打开 URL（在新标签页）',
  goto: '在当前标签页导航到 URL',
  snapshot: '获取当前页面快照',
  screenshot: '截图当前页面',
  tabs: '列出所有标签页',
  console: '查看控制台日志',
  network: '查看网络请求',
  close: '关闭 Edge 浏览器',
  help: '显示帮助信息'
};

// 显示帮助信息
function showHelp() {
  console.log('edge-cli - Edge 浏览器控制工具\n');
  console.log('用法: edge-cli <command> [args]\n');
  console.log('命令:');
  Object.entries(commands).forEach(([cmd, desc]) => {
    console.log(`  ${cmd.padEnd(12)} ${desc}`);
  });
  console.log('\n示例:');
  console.log('  edge-cli start');
  console.log('  edge-cli open https://example.com');
  console.log('  edge-cli tabs');
  console.log('  edge-cli screenshot');
}

// 检查 Edge 是否运行（轻量级检测）
async function checkEdge() {
  return new Promise((resolve) => {
    // 使用 127.0.0.1 而不是 localhost，避免 IPv6 解析问题
    const req = http.get('http://127.0.0.1:9222/json/version', (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        try {
          const json = JSON.parse(data);
          resolve({ running: true, info: json });
        } catch (error) {
          resolve({ running: false, error: 'Invalid response format' });
        }
      });
    });

    req.on('error', (error) => {
      resolve({ running: false, error: error.message });
    });

    req.setTimeout(5000, () => {
      req.destroy();
      resolve({ running: false, error: 'Connection timeout' });
    });
  });
}

// 连接到 Edge（带重试和超时配置）
async function connectToEdge(options = {}) {
  const { timeout = 60000, retries = 3, silent = false } = options;

  for (let i = 0; i < retries; i++) {
    try {
      if (i > 0 && !silent) {
        console.log(`正在重试连接... (${i + 1}/${retries})`);
        await new Promise(resolve => setTimeout(resolve, 2000));
      }

      const browser = await puppeteer.connect({
        browserURL: CDP_URL,
        defaultViewport: null,
        timeout
      });
      return browser;
    } catch (error) {
      if (i === retries - 1) {
        throw new Error(`连接失败（已重试 ${retries} 次）: ${error.message}`);
      }
    }
  }
}

// 启动 Edge
async function startEdge() {
  const status = await checkEdge();
  if (status.running) {
    console.log('✅ Edge 已经在运行');
    console.log(`   浏览器版本: ${status.info.Browser}`);
    return true;
  }

  console.log('正在启动 Edge...');

  try {
    await execAsync(`cmd /c "${EDGE_SCRIPT}"`);

    // 等待 Edge 启动
    console.log('等待 Edge 启动...');
    await new Promise(resolve => setTimeout(resolve, 3000));

    const newStatus = await checkEdge();
    if (newStatus.running) {
      console.log('✅ Edge 启动成功');
      console.log(`   浏览器版本: ${newStatus.info.Browser}`);
      return true;
    } else {
      console.error('❌ Edge 启动失败:', newStatus.error);
      return false;
    }
  } catch (error) {
    console.error('❌ 启动 Edge 失败:', error.message);
    return false;
  }
}

// 检查命令
async function checkCommand() {
  const status = await checkEdge();
  if (status.running) {
    console.log('✅ Edge 正在运行');
    console.log(`   浏览器版本: ${status.info.Browser}`);
    console.log(`   协议版本: ${status.info['Protocol-Version']}`);
    console.log(`   WebSocket: ${status.info.webSocketDebuggerUrl}`);
  } else {
    console.log('❌ Edge 未运行');
    console.log(`   原因: ${status.error}`);
    console.log('\n提示: 运行 "edge-cli start" 启动 Edge');
  }
}

// 诊断命令
async function diagnose() {
  console.log('=== Edge 连接诊断 ===\n');

  // 1. 检查端口
  console.log('1. 检查端口 9222...');
  const status = await checkEdge();

  if (!status.running) {
    console.log(`   ❌ 端口无法访问: ${status.error}`);
    console.log('\n建议：');
    console.log('  - 确认 Edge 是否运行');
    console.log('  - 运行 start-edge-debug.bat 启动 Edge');
    console.log('  - 检查防火墙设置');
    return;
  }

  console.log('   ✅ 端口可访问');
  console.log(`   浏览器: ${status.info.Browser}`);
  console.log(`   协议版本: ${status.info['Protocol-Version']}`);

  // 2. 测试 Puppeteer 连接
  console.log('\n2. 测试 Puppeteer 连接...');
  try {
    const browser = await connectToEdge({ timeout: 60000, retries: 1, silent: true });
    console.log('   ✅ Puppeteer 连接成功');

    const pages = await browser.pages();
    console.log(`   标签页数量: ${pages.length}`);

    await browser.disconnect();
  } catch (error) {
    console.log('   ❌ Puppeteer 连接失败');
    console.log(`   错误: ${error.message}`);
    console.log('\n可能的原因：');
    console.log('  - Edge 版本与 Puppeteer 不兼容');
    console.log('  - CDP 协议版本不匹配');
    console.log('  - 需要更新 Puppeteer: npm install puppeteer-core');
  }

  console.log('\n=== 诊断完成 ===');
}

// 打开 URL（新标签页）
async function openUrl(url) {
  if (!url) {
    console.error('❌ 请提供 URL');
    console.log('用法: edge-cli open <url>');
    return;
  }

  // 确保 Edge 运行
  const status = await checkEdge();
  if (!status.running) {
    console.log('Edge 未运行，正在启动...');
    const started = await startEdge();
    if (!started) return;
  }

  console.log(`正在打开: ${url}`);

  try {
    const browser = await connectToEdge();

    const page = await browser.newPage();
    await page.goto(url, { waitUntil: 'networkidle2' });

    const title = await page.title();
    console.log(`✅ 页面已打开: ${title}`);
    console.log(`   URL: ${page.url()}`);

    await browser.disconnect();
  } catch (error) {
    console.error('❌ 打开页面失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 导航到 URL（当前标签页）
async function gotoUrl(url) {
  if (!url) {
    console.error('❌ 请提供 URL');
    console.log('用法: edge-cli goto <url>');
    return;
  }

  try {
    const browser = await connectToEdge();
    const pages = await browser.pages();

    if (pages.length === 0) {
      console.log('没有打开的标签页，创建新标签页...');
      await browser.disconnect();
      await openUrl(url);
      return;
    }

    const page = pages[0];
    console.log(`正在导航到: ${url}`);
    await page.goto(url, { waitUntil: 'networkidle2' });

    const title = await page.title();
    console.log(`✅ 导航成功: ${title}`);

    await browser.disconnect();
  } catch (error) {
    console.error('❌ 导航失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 获取快照
async function takeSnapshot(filename) {
  try {
    const browser = await connectToEdge();
    const pages = await browser.pages();

    if (pages.length === 0) {
      console.log('❌ 没有打开的标签页');
      await browser.disconnect();
      return;
    }

    const page = pages[0];
    const title = await page.title();
    const url = page.url();

    console.log('=== 页面快照 ===');
    console.log(`标题: ${title}`);
    console.log(`URL: ${url}`);

    // 获取完整的页面文本内容
    const content = await page.evaluate(() => {
      return document.body.innerText;
    });
    console.log(`\n内容:\n${content}`);

    if (filename) {
      const snapshotData = {
        title,
        url,
        timestamp: new Date().toISOString(),
        content: await page.content()
      };
      fs.writeFileSync(filename, JSON.stringify(snapshotData, null, 2));
      console.log(`✅ 快照已保存: ${filename}`);
    }

    await browser.disconnect();
  } catch (error) {
    console.error('❌ 获取快照失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 截图
async function takeScreenshot(filename) {
  const imgsDir = 'imgs';

  // 确保 imgs 目录存在
  if (!fs.existsSync(imgsDir)) {
    fs.mkdirSync(imgsDir, { recursive: true });
  }

  // 处理文件名
  let outputFile;
  if (filename) {
    // 如果用户指定了文件名，检查是否包含路径
    if (path.dirname(filename) === '.') {
      // 没有指定路径，添加 imgs/ 前缀
      outputFile = path.join(imgsDir, filename);
    } else {
      // 用户指定了完整路径，使用用户指定的路径
      outputFile = filename;
    }
  } else {
    // 使用默认文件名，保存到 imgs 目录
    const defaultFilename = `edge-screenshot-${Date.now()}.png`;
    outputFile = path.join(imgsDir, defaultFilename);
  }

  try {
    const browser = await connectToEdge();
    const pages = await browser.pages();

    if (pages.length === 0) {
      console.log('❌ 没有打开的标签页');
      await browser.disconnect();
      return;
    }

    const page = pages[0];
    console.log('正在截图...');

    // 使用 Puppeteer 的 screenshot 方法
    await page.screenshot({ path: outputFile });

    console.log(`✅ 截图已保存: ${outputFile}`);

    await browser.disconnect();
  } catch (error) {
    console.error('❌ 截图失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 列出标签页
async function listTabs() {
  try {
    const browser = await connectToEdge();
    const pages = await browser.pages();

    console.log(`=== Edge 标签页 (${pages.length}) ===\n`);

    for (let i = 0; i < pages.length; i++) {
      const page = pages[i];
      const title = await page.title();
      const url = page.url();
      console.log(`[${i + 1}] ${title}`);
      console.log(`    ${url}\n`);
    }

    await browser.disconnect();
  } catch (error) {
    console.error('❌ 获取标签页失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 查看控制台日志
async function viewConsole() {
  try {
    const browser = await connectToEdge();
    const pages = await browser.pages();

    if (pages.length === 0) {
      console.log('❌ 没有打开的标签页');
      await browser.disconnect();
      return;
    }

    const page = pages[0];
    console.log('=== 控制台日志 ===\n');

    // 监听控制台消息
    const messages = [];
    page.on('console', msg => messages.push(msg));

    // 等待一小段时间收集消息
    await new Promise(resolve => setTimeout(resolve, 1000));

    if (messages.length === 0) {
      console.log('暂无控制台消息');
    } else {
      messages.forEach(msg => {
        console.log(`[${msg.type()}] ${msg.text()}`);
      });
    }

    await browser.disconnect();
  } catch (error) {
    console.error('❌ 获取控制台日志失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 关闭 Edge
async function closeEdge() {
  try {
    const browser = await connectToEdge();
    const pages = await browser.pages();

    console.log('正在关闭 Edge...');

    // 关闭所有页面
    for (const page of pages) {
      await page.close();
    }

    await browser.disconnect();
    console.log('✅ Edge 已关闭');
  } catch (error) {
    console.error('❌ 关闭 Edge 失败:', error.message);
    console.log('\n故障排除: 运行 "edge-cli diagnose" 进行诊断');
  }
}

// 主函数
async function main() {
  const command = process.argv[2];
  const args = process.argv.slice(3);

  if (!command || command === 'help' || command === '--help' || command === '-h') {
    showHelp();
    return;
  }

  try {
    switch (command) {
      case 'start':
        await startEdge();
        break;
      case 'check':
        await checkCommand();
        break;
      case 'diagnose':
        await diagnose();
        break;
      case 'open':
        await openUrl(args[0]);
        break;
      case 'goto':
        await gotoUrl(args[0]);
        break;
      case 'snapshot':
        await takeSnapshot(args[0]);
        break;
      case 'screenshot':
        await takeScreenshot(args[0]);
        break;
      case 'tabs':
        await listTabs();
        break;
      case 'console':
        await viewConsole();
        break;
      case 'close':
        await closeEdge();
        break;
      default:
        console.error(`❌ 未知命令: ${command}`);
        console.log('运行 "edge-cli help" 查看帮助');
    }
  } catch (error) {
    console.error('❌ 执行失败:', error.message);
    process.exit(1);
  }
}

// 运行
if (require.main === module) {
  main();
}

module.exports = { checkEdge, startEdge };
