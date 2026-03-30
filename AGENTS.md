# Agent Operating Rules

## 可用 Skills（所有工具必须读取）
本项目在 `.agents/skills/` 下内置了以下 Skills，执行任务前先检查是否匹配：

| Skill | 路径 | 触发场景 |
|-------|------|---------|
| harness-setup | .agents/skills/harness-setup/SKILL.md | 首次使用、初始化 |
| verification | .agents/skills/verification/SKILL.md | 验证、验收、测试 |
| maintenance | .agents/skills/maintenance/SKILL.md | 维护、清理、文档更新 |
| error-permanence | .agents/skills/error-permanence/SKILL.md | 修复、bug、报错 |

> Codex 自动扫描加载。其他工具（Trae / Antigravity / Cursor）在任务开始前手动读取匹配的 SKILL.md。

## 项目初始化（首次使用必须执行）
如果 `.git/hooks/pre-commit` 不存在，必须先执行以下命令：
```bash
cp bootstrap/hooks/pre-commit .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```
安装完成后再开始任何任务。

## 项目上下文
<!-- 项目启动时填写：一句话说明这个项目做什么 -->
- 项目名称：
- 核心目标：
- 技术栈：
- 项目类型：一次性 Demo / 长期迭代（影响验证工具选择）

## 工作流程
1. 读取 PRD.md 获取项目目标与技术规格（最高优先级）
2. 读取 docs/change-log.md 了解需求变更历史
3. 读取 docs/conventions.md，所有输出必须符合规范
4. 读取 docs/verification-protocol.md，确定验证工具
5. 读取 STATE.md 了解当前进度与遗留问题
6. 读取 tasks/ 中当前任务
7. 按需读取 docs/ 中与当前任务相关的文件（见文件读取规则）
8. 输出执行计划（先计划，再动手）
9. 做最小修改
10. 按 verification-protocol.md 选择对应验证工具运行验证
11. 写入 logs/ 执行日志
12. 更新 STATE.md
13. 输出报告到 reports/

## 文件读取规则（省 Token）

> 上下文是稀缺资源。所有内容都"重要"时，就没有什么是重要的。

### 必须读取（每次任务都读）
- `PRD.md`
- `docs/change-log.md`
- `docs/conventions.md`
- `docs/verification-protocol.md`
- `STATE.md`
- 当前任务文件 `tasks/task-{id}.md`

### 按需读取（任务涉及时才读）
- `docs/architecture.md` → 涉及系统结构时
- `docs/data-schema/` → 涉及数据格式时
- `docs/runbooks/` → 涉及部署/运行时
- `docs/risks/` → 评估风险时
- `docs/decisions/` → 遇到技术选型争议时
- `docs/technical-debt/` → 重构或清理时
- `docs/blocked.md` → 遇到阻塞时

### 禁止行为
- 禁止一次性加载整个 `docs/` 目录
- 禁止读取与当前任务无关的文件
- 禁止重复读取已在上下文中的文件

---

## 约束
- 不允许跳过测试
- 不允许直接修改主分支
- 不允许大范围重构（除非任务明确要求）
- 所有修改必须可回滚
- 验收标准必须是可执行命令或可断言的输出，不接受模糊描述
- 验证结果必须附真实命令输出，不接受描述性语言
- PRD.md 变更时，旧内容标注"已完成/已作废"，不允许直接删除
- 遇到阻塞时，必须按 docs/blocked.md 规定流程处理，不允许静默跳过
- 每次出错修复后，必须执行错误永久化（见 .agents/skills/error-permanence/SKILL.md）

## 遇到阻塞时（强制）
当任务执行遇到阻塞，立即执行：
1. 停止当前任务
2. 按 docs/blocked.md 格式写入 workspace/blocked-{task-id}-{date}.md
3. 更新 STATE.md，任务状态改为"已阻塞"
4. 输出阻塞报告，等待人工处理
5. 修复后把根本原因永久化为规则，写进对应 docs/ 文件

## 出错修复后（强制）
加载 .agents/skills/error-permanence/SKILL.md 执行错误永久化流程。

## 任务结束前强制自查清单
每次任务结束前，必须逐项确认：

- [ ] 所有验收命令已实际运行（非推断）
- [ ] 报告中验证结果附有真实输出（非描述）
- [ ] 所有验收项明确为 Yes / No
- [ ] logs/ 下已写入本次执行日志
- [ ] STATE.md 已更新
- [ ] 未在任务范围外修改任何文件
- [ ] 所有修改可通过 git revert 回滚
- [ ] 若有出错，已完成错误永久化

## 输出格式（每次任务结束必须输出）
- 做了什么
- 修改内容（精确到文件）
- 验证结果（附实际命令和输出）
- 验收结论（Yes/No 表格）
- 错误永久化记录（若有）
- 风险点
- 下一步建议

---

## 权限控制（三级权限模式）

> 所有操作必须按以下分级执行，不允许越级。

### Auto（自动执行，无需确认）
以下操作风险低，AI 直接执行：
- 读取任何文件（Read）
- 搜索、grep、列目录
- 运行测试命令（pytest、npm test 等）
- git log、git diff、git status

### Approval（需要人工确认）
以下操作影响文件或状态，执行前必须输出计划等待确认：
- 写入或修改任何文件（Write / Edit）
- git commit、git push
- 安装新依赖（pip install、npm install）
- 创建或删除目录

### Deny（禁止执行，无论如何不允许）
以下操作永久禁止：
- `rm -rf`、批量删除
- 修改 `.env` 或任何含密钥的文件
- 直接操作生产环境
- 访问 `src/` 以外的系统目录

---

## MCP 工具调用规则（省 Token）

> 传统方式把所有工具定义加载进上下文（消耗大量 Token）。
> 正确做法：按需加载，用代码调用工具而不是逐跳推理。

### 工具调用原则
- 优先用**代码方式**调用 MCP 工具（Code Mode），而非逐步推理每次调用
- 只加载当前任务需要的工具，不加载全部工具定义
- 工具调用结果直接返回，不在上下文中保留中间过程

### 当前项目可用 MCP 工具
<!-- 项目启动时填写，只列实际需要的工具 -->
- 工具1：（用途）
- 工具2：（用途）

### 禁止行为
- 禁止一次性加载所有 MCP 工具定义
- 禁止在不需要外部工具时强行调用 MCP
- 禁止把工具调用的中间结果留在主上下文中

---

## 上下文管理规则（重置而非压缩）

> 来源：Anthropic 工程博客《Harness design for long-running application development》
> 核心原则：上下文重置（Context Reset）而非压缩（Compaction）。
> 清空上下文，用结构化文件完整交接状态，让新 Agent "轻装上阵"。

### 触发条件
当 AI 判断当前会话上下文已使用约 40% 时，必须主动执行：

1. **把完整状态写进 STATE.md**：
   - 当前任务进行到哪一步
   - 已完成的子任务列表
   - 尚未解决的问题
   - 下一步要做什么
   - 任何重要的上下文决策

2. **确认 Sprint 合同已写入文件**：
   - workspace/sprint-contract-{id}.md 必须是最新的

3. **输出重置提示**：
   ```
   ⚠️ 上下文接近限制，完整状态已写入 STATE.md。
   请开启新会话，使用 PROMPTS.md 中的"上下文重置后恢复任务"触发语继续。
   ```

4. **不允许**在上下文即将耗尽时才通知，必须提前主动处理。

### 与压缩的区别
- **压缩**：保留历史，摘要旧内容（Opus 4.5+ 可用 SDK 自动完成）
- **重置**：清空历史，完全依赖文件交接——这是本模板的默认方式
- 随着模型能力提升（Opus 4.5+），可直接使用 SDK 自动 Compaction，本规则可简化

---

## 循环控制：重试 vs Escalate

> 基于 OpenAI Codex 原文实现：失败时明确判断重试还是停止，不允许无限循环。

### 判断决策树

```
失败发生
  │
  ├── 同一错误已出现 3 次以上？
  │     └── 是 → 立即停止，Escalate 人工处理
  │
  ├── 是网络超时 / 限流（429）？
  │     └── 是 → 指数退避重试（1s → 2s → 4s），最多 3 次
  │
  ├── 是权限错误 / 验证失败 / 策略拒绝？
  │     └── 是 → 立即停止（重试不会改善）
  │
  ├── 错误原因明确，可以直接修复？
  │     └── 是 → 修复后重试一次，失败则 Escalate
  │
  └── 原因不明确？
        └── 是 → 立即 Escalate，不猜测原因
```

### 重试规则
- 最大重试次数：**3 次**（含首次）
- 每次重试前必须说明：上次失败原因 + 本次修改了什么
- 重试超过 3 次仍失败：强制 Escalate，禁止继续尝试

### Escalate 规则
触发 Escalate 时，必须执行：
1. 停止当前任务
2. 按 `docs/blocked.md` 格式写入阻塞报告
3. 在报告中说明：已尝试的方法、失败原因、需要人工提供什么
4. 更新 STATE.md，任务状态改为"已阻塞"

### Kill Switch（强制终止）
以下情况无论如何立即终止，不重试不 Escalate：
- 检测到破坏性操作（`rm -rf`、批量覆盖）
- 循环次数超过 10 次
- 发现未经授权的文件被修改
