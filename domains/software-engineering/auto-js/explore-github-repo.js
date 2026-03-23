const { chromium } = require('playwright');
const fs = require('fs');

// 使用方法: node explore-github-repo.js <github-url>
const repoUrl = process.argv[2] || 'https://github.com/affaan-m/everything-claude-code';

(async () => {
  try {
    console.log(`开始探索 GitHub 仓库: ${repoUrl}\n`);

    const browser = await chromium.connectOverCDP('http://localhost:9222');
    const contexts = browser.contexts();
    const pages = await contexts[0].pages();
    const page = pages[pages.length - 1];

    // 导航到 GitHub 仓库
    console.log('[1/5] 导航到仓库页面...');
    await page.goto(repoUrl, { waitUntil: 'networkidle' });
    await page.waitForTimeout(2000);

    // 提取仓库基本信息
    console.log('[2/5] 提取仓库信息...');
    const repoInfo = await page.evaluate(() => {
      const getTextContent = (selector) => {
        const el = document.querySelector(selector);
        return el ? el.textContent.trim() : '';
      };

      return {
        name: getTextContent('h1 strong a') || getTextContent('h1'),
        description: getTextContent('[data-pjax="#repo-content-pjax-container"] p') || getTextContent('.f4.my-3'),
        stars: getTextContent('#repo-stars-counter-star'),
        forks: getTextContent('#repo-network-counter'),
        language: getTextContent('[itemprop="programmingLanguage"]'),
        license: getTextContent('[data-testid="license-link"]'),
      };
    });

    console.log(`  仓库名: ${repoInfo.name}`);
    console.log(`  描述: ${repoInfo.description}`);
    console.log(`  Stars: ${repoInfo.stars}`);
    console.log(`  语言: ${repoInfo.language}`);

    // 展开 README（如果被折叠）
    console.log('[3/5] 展开 README 内容...');
    try {
      const readMoreButton = await page.$('button:has-text("Read more")');
      if (readMoreButton) {
        await readMoreButton.click();
        await page.waitForTimeout(1000);
        console.log('  ✓ README 已展开');
      }
    } catch (e) {
      console.log('  - README 无需展开');
    }

    // 提取 README 内容
    console.log('[4/5] 提取 README 内容...');
    const readmeContent = await page.evaluate(() => {
      const readme = document.querySelector('article.markdown-body') ||
                     document.querySelector('[data-testid="readme"]') ||
                     document.querySelector('#readme');

      if (readme) {
        return {
          html: readme.innerHTML,
          text: readme.innerText,
          headings: Array.from(readme.querySelectorAll('h1, h2, h3, h4, h5, h6')).map(h => ({
            level: h.tagName,
            text: h.innerText.trim()
          })),
          links: Array.from(readme.querySelectorAll('a')).map(a => ({
            text: a.innerText.trim(),
            href: a.href
          }))
        };
      }
      return null;
    });

    if (readmeContent) {
      console.log(`  ✓ README 提取成功 (${readmeContent.text.length} 字符)`);
      console.log(`  ✓ 发现 ${readmeContent.headings.length} 个标题`);
    } else {
      console.log('  - 未找到 README');
    }

    // 提取文件结构
    console.log('[5/5] 提取文件结构...');
    const fileStructure = await page.evaluate(() => {
      const files = Array.from(document.querySelectorAll('[aria-labelledby="files"] .react-directory-row, [aria-labelledby="files"] .Box-row'));

      return files.map(file => {
        const nameEl = file.querySelector('a[href*="/blob/"], a[href*="/tree/"]');
        const typeEl = file.querySelector('[aria-label*="Directory"], [aria-label*="File"]');

        return {
          name: nameEl ? nameEl.textContent.trim() : '',
          type: typeEl ? (typeEl.getAttribute('aria-label').includes('Directory') ? 'directory' : 'file') : 'unknown',
          path: nameEl ? nameEl.getAttribute('href') : ''
        };
      }).filter(f => f.name);
    });

    console.log(`  ✓ 发现 ${fileStructure.length} 个文件/文件夹`);

    // 汇总所有信息
    const result = {
      url: repoUrl,
      timestamp: new Date().toISOString(),
      repository: repoInfo,
      readme: readmeContent,
      fileStructure: fileStructure,
      pageTitle: await page.title(),
      pageUrl: page.url()
    };

    // 保存结果
    const filename = `github-repo-${Date.now()}.json`;
    fs.writeFileSync(filename, JSON.stringify(result, null, 2));

    console.log(`\n✓ 探索完成！`);
    console.log(`✓ 结果已保存到: ${filename}`);

    // 输出 README 预览
    if (readmeContent && readmeContent.text) {
      console.log(`\n--- README 预览 (前 500 字符) ---`);
      console.log(readmeContent.text.substring(0, 500));
      console.log('...\n');
    }

  } catch (error) {
    console.error('探索过程中出错:', error.message);
    console.error(error.stack);
  }
})();
