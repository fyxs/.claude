const fs = require('fs');
const path = require('path');

const configPath = 'C:/Users/admin/.claude.json';
const sourcePath = 'C:/Users/admin/.claude/mcp.json';

console.log('=== MCP 配置同步工具 ===\n');

// 检查配置文件
if (!fs.existsSync(configPath)) {
  console.log('[错误] 找不到配置文件:', configPath);
  process.exit(1);
}

// 检查源 MCP 文件
if (!fs.existsSync(sourcePath)) {
  console.log('[错误] 找不到源 MCP 文件:', sourcePath);
  process.exit(1);
}

// 读取源 MCP 配置
const sourceContent = fs.readFileSync(sourcePath, 'utf8');
console.log(`源文件: ${sourcePath}`);
console.log(`大小: ${sourceContent.length} 字节\n`);

// 读取项目列表
const data = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const projects = Object.keys(data.projects || {});

console.log(`找到 ${projects.length} 个项目\n`);

let checked = 0, synced = 0, skipped = 0, upToDate = 0, errors = 0;

for (const dir of projects) {
  // 跳过根路径
  if (dir === 'C:/' || dir === 'C:') {
    console.log(`[跳过] ${dir} (根路径)`);
    skipped++;
    continue;
  }

  const normalizedDir = dir.replace(/\\/g, '/');
  const targetPath = normalizedDir + '/.mcp.json';

  checked++;

  try {
    // 检查项目目录是否存在
    if (!fs.existsSync(normalizedDir)) {
      console.log(`[跳过] ${dir} (项目不存在)`);
      skipped++;
      continue;
    }

    // 检查目标文件是否已存在且内容相同
    if (fs.existsSync(targetPath)) {
      const targetContent = fs.readFileSync(targetPath, 'utf8');
      if (targetContent === sourceContent) {
        console.log(`[最新] ${dir}`);
        upToDate++;
        continue;
      }
    }

    // 写入 MCP 配置
    fs.writeFileSync(targetPath, sourceContent, 'utf8');
    console.log(`[同步] ${dir}`);
    synced++;

  } catch (e) {
    console.log(`[错误] ${dir} - ${e.message}`);
    errors++;
  }
}

console.log('\n=== 总结 ===');
console.log(`检查: ${checked} 个项目`);
console.log(`已同步: ${synced} 个`);
console.log(`已是最新: ${upToDate} 个`);
console.log(`跳过: ${skipped} 个`);
console.log(`错误: ${errors} 个`);

if (synced > 0) {
  console.log(`\n✅ 成功同步 ${synced} 个项目的 MCP 配置`);
} else if (upToDate > 0) {
  console.log('\n✅ 所有项目的 MCP 配置都已是最新');
} else {
  console.log('\n⚠️ 没有项目需要同步');
}
