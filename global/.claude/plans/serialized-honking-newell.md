# Context
用户希望仅在 `D:\2Work\Claude\ts-projects\isms-web` 项目层“做实验”并改写项目开发工作流，不影响其它层级规则。目标是将高效的 E2E/Playwright/Midscene 实战流程纳入项目层工作流说明，成为可执行的项目特定流程。

# Approach
1. **补齐项目层 E2E 流程依据**
   - 在实现阶段先读取并提炼项目层记忆文档中的 E2E/Playwright/Midscene 实践规则，作为改写内容依据：
     - `isms-web/.claude/memory/e2e-testing-guide.md`
     - `isms-web/.claude/memory/e2e-workflow.md`
     - `isms-web/.claude/memory/playwright-cli-interaction-principles.md`
     - `isms-web/.claude/memory/midscene-workflow.md`
     - `isms-web/.claude/memory/midscene-experience.md`

2. **改写项目层开发工作流**
   - 主要修改 `isms-web/.claude/rules/project-development-workflow.md`，新增“E2E 自动化测试最小操作链”与“关键流程触发条件”，并明确：
     - 何时必须运行 `npm run test:e2e`（如核心流程变更/发布前/回归）
     - Playwright UI 调试与重新认证命令（来自 `isms-web/CLAUDE.md`）
     - Midscene + Playwright 的使用边界与最佳实践（从 memory 文档提炼）
   - 保持与上层规则一致（TDD、code-reviewer/security-reviewer、覆盖率要求），不修改上层文件。

3. **保持引用一致性**
   - 在工作流中引用既有项目文档入口（`isms-web/CLAUDE.md` 中的 E2E 命令与记忆文档索引）。
   - 不新增跨层规则文件，确保“只影响项目层”。

# Files to modify
- `D:\2Work\Claude\ts-projects\isms-web\.claude\rules\project-development-workflow.md`

# Existing references to reuse
- `D:\2Work\Claude\ts-projects\isms-web\CLAUDE.md`（E2E 命令与文档索引）
- `D:\2Work\Claude\ts-projects\isms-web\.claude\memory\*`（E2E/Playwright/Midscene 实战规则）

# Verification
- 文档层验证：确认新增流程条目与命令准确引用现有命令与记忆文档。
- 若需要真实执行验证（实现阶段再确认）：
  - `npm run ts-check`
  - `npm run lint`
  - `npm run test:e2e`
  - `npx playwright test --ui`（调试时）
