#!/usr/bin/env node

/**
 * Strategic Compact Suggester (Node.js 版本)
 *
 * 在 PreToolUse 钩子中运行，追踪工具调用次数，
 * 在达到阈值时建议用户执行 /compact 以优化 token 使用。
 *
 * 原理：
 * - 自动压缩会在任意时间点触发，可能丢失重要上下文
 * - 策略性压缩在逻辑边界点执行，保留关键信息
 * - 在探索→执行、调试→新功能等阶段切换时压缩最有效
 */

const fs = require('fs');
const path = require('path');
const os = require('os');

// 配置
const THRESHOLD = parseInt(process.env.COMPACT_THRESHOLD || '50', 10);
const REMINDER_INTERVAL = 25;

// 使用会话 ID 区分不同会话的计数器
const sessionId = process.env.CLAUDE_SESSION_ID || process.ppid || 'default';
const counterFile = path.join(os.tmpdir(), `claude-tool-count-${sessionId}`);

// 读取或初始化计数器
let count = 1;
try {
  if (fs.existsSync(counterFile)) {
    count = parseInt(fs.readFileSync(counterFile, 'utf-8').trim(), 10) + 1;
  }
} catch {
  count = 1;
}

// 写入新计数
fs.writeFileSync(counterFile, String(count), 'utf-8');

// 在阈值时首次建议
if (count === THRESHOLD) {
  console.error(
    `[StrategicCompact] 已达 ${THRESHOLD} 次工具调用 — 如果正在切换任务阶段，建议执行 /compact 优化上下文`
  );
}

// 超过阈值后定期提醒
if (count > THRESHOLD && count % REMINDER_INTERVAL === 0) {
  console.error(
    `[StrategicCompact] 已累计 ${count} 次工具调用 — 建议检查是否需要 /compact 清理过期上下文`
  );
}
