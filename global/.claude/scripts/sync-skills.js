const fs = require('fs');
const path = require('path');
const cp = require('child_process');

const configPath = 'C:/Users/admin/.claude.json';
const source = 'C:/Users/admin/.claude/skills';

console.log('=== Skills Junction 检查和修复工具 ===\n');

if (!fs.existsSync(configPath)) {
  console.log('[错误] 找不到配置文件:', configPath);
  process.exit(1);
}

if (!fs.existsSync(source)) {
  console.log('[错误] 找不到源 skills 目录:', source);
  process.exit(1);
}

const data = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const projects = Object.keys(data.projects || {});

console.log(`找到 ${projects.length} 个项目\n`);

let checked = 0, ok = 0, missing = 0, created = 0, errors = 0;

function isSymlinkOrJunction(p) {
  try {
    const stat = fs.lstatSync(p);
    return stat.isSymbolicLink();
  } catch (_) {
    return false;
  }
}

for (const dir of projects) {
  // 跳过根路径和源目录
  if (dir === 'C:/' || dir === 'C:' || dir === 'C:/Users/admin') {
    console.log(`[跳过] ${dir} (根路径或源目录)`);
    continue;
  }

  const normalizedDir = dir.replace(/\\/g, '/').replace(/\/$/, '');
  const claudeDir = normalizedDir + '/.claude';
  const target = claudeDir + '/skills';

  checked++;

  try {
    // 检查项目目录是否存在
    if (!fs.existsSync(normalizedDir)) {
      console.log(`[跳过] ${dir} (项目不存在)`);
      continue;
    }

    // 确保 .claude 目录存在
    if (!fs.existsSync(claudeDir)) {
      fs.mkdirSync(claudeDir, { recursive: true });
      console.log(`[创建] ${dir}/.claude 目录`);
    }

    // 检查 skills junction
    if (fs.existsSync(target)) {
      if (isSymlinkOrJunction(target)) {
        const real = fs.realpathSync(target).replace(/\\/g, '/');
        const srcReal = fs.realpathSync(source).replace(/\\/g, '/');
        if (real === srcReal) {
          console.log(`[正常] ${dir}`);
          ok++;
          continue;
        } else {
          console.log(`[警告] ${dir} (指向错误的位置: ${real})`);
          missing++;
          continue;
        }
      } else {
        console.log(`[警告] ${dir} (skills 是普通目录，不是 junction)`);
        missing++;
        continue;
      }
    }

    // 需要创建 junction
    console.log(`[缺失] ${dir} - 正在创建...`);
    missing++;

    const targetWin = target.replace(/\//g, '\\');
    const sourceWin = source.replace(/\//g, '\\');

    try {
      cp.execSync(
        `powershell.exe -Command "New-Item -ItemType Junction -Path '${targetWin}' -Target '${sourceWin}' -Force | Out-Null"`,
        { stdio: 'pipe' }
      );
      console.log(`[成功] ${dir} - Junction 已创建`);
      created++;
    } catch (e) {
      console.log(`[失败] ${dir} - ${e.message}`);
      errors++;
    }
  } catch (e) {
    console.log(`[错误] ${dir} - ${e.message}`);
    errors++;
  }
}

console.log('\n=== 总结 ===');
console.log(`检查: ${checked} 个项目`);
console.log(`正常: ${ok} 个`);
console.log(`缺失: ${missing} 个`);
console.log(`创建: ${created} 个`);
console.log(`错误: ${errors} 个`);
