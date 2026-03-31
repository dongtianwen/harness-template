# 触发语手册（PROMPTS.md）

> 按流程顺序复制使用，不需要记任何指令。
> 完整流程说明见 docs/flow.md。

---

## Step 1：需求整理
> 使用架构设计工作流（外部）完成，输出结果填入 PRD.md。
> 此步骤无触发语，需人工操作。

---

## Step 2：范围冻结
> PRD.md 阶段 3 填写完成后，此步骤自动完成。
> 此步骤无触发语，需人工确认技术规格。

---

## Step 3a：Planner（需求 → 完整产品规格）

> 适用于复杂项目。简单项目可跳过直接到 Step 3b。

```
你是 Planner Agent。
读取 PRD.md 中的需求描述。

请输出完整产品规格，包含：
1. 核心功能列表（每个功能一句话描述，不超过 16 条）
2. AI 特性集成点（如有）
3. 设计语言定义（视觉风格、交互原则）
4. 技术架构概要（不锁定细节，只定方向）
5. Sprint 拆分建议（每个 Sprint 一个独立功能）

要求：
- 高层次产品思考，避免过早锁定实现细节
- 每个 Sprint 必须是独立可验收的功能单元
- 输出结果写入 docs/product-spec.md
```

> 生成后人工确认产品规格，再进入 Step 3b。

---

## Step 3b：任务拆解

```
读取 PRD.md 和 docs/product-spec.md（如有），按照 tasks/task-template.md 的格式和 docs/conventions.md 的任务拆解规则，自动拆解任务列表，生成对应的 task-{id}.md 文件，并更新 tasks/README.md 索引。
```

> ⚠️ 生成后人工确认任务列表合理性，再进入 Step 4。

---

## Step 4 前置：Sprint 合同谈判

> 每个 Sprint 开始前必须执行，减少预期偏差。
> Generator 和 Evaluator 先就"做什么 + 怎么验收"达成一致。

**第一步：Generator 提出合同草案**
```
你是 Generator Agent。
读取 tasks/task-{id}.md。

请输出 Sprint 合同草案，包含：
1. 本次 Sprint 要实现什么（具体功能，不超过 5 条）
2. 不做什么（明确边界）
3. 完成的验收标准（可执行命令或可断言的输出）
4. 预计修改哪些文件

将草案写入 workspace/sprint-contract-{id}.md，等待 Evaluator 审核。
```

**第二步：Evaluator 审核合同**
```
你是 Evaluator Agent。
读取 workspace/sprint-contract-{id}.md 和 tasks/task-{id}.md。

审核合同草案：
1. 验收标准是否客观可执行？（不接受"功能正常"等模糊描述）
2. 功能边界是否清晰？
3. 是否遗漏关键验收项？

输出：同意 / 需修改（附具体修改意见）
若需修改，Generator 更新合同后重新提交，直到双方一致。
合同确认后在文件末尾注明：✅ 合同已确认 {日期}
```

> 合同确认后再执行 Step 4 Generator 触发语。

---

## Step 4 执行：Generator（只负责写代码）

```
你是 Generator Agent。
读取 AGENTS.md、PRD.md、STATE.md、workspace/sprint-contract-{id}.md 和 tasks/task-{id}.md。
严格按照已确认的 Sprint 合同实现，不超出合同范围。
只负责实现代码，不做验收判断。
完成后输出：做了什么、修改了哪些文件。
不要输出验收结论。
```

---

## Step 4 验证：Evaluator（独立验证，消除自我评估偏差）

```
你是 Evaluator Agent，独立于代码实现过程。
读取 workspace/sprint-contract-{id}.md 中已确认的验收标准。
不看代码实现，只从用户视角实际测试：

如果当前环境支持 Chrome DevTools MCP：
  使用浏览器工具直接验证界面输出（DOM 快照、截图、交互测试）

如果仓库已提供 Playwright 测试脚本且工具支持终端执行：
  优先运行 playwright test，输出实际结果

否则：
  运行验收命令，输出真实终端结果

对每一项验收标准输出 Yes / No + 实际证据。
若任何一项为 No，不允许关闭任务，必须说明原因。
完成后按 reports/README.md 格式输出完整报告，更新 STATE.md。
```

> 模板默认兼容策略：MCP 优先、Playwright 标配、命令行兜底。

---

## Step 5：验收交付

```
读取所有 reports/ 下的任务报告，生成 reports/delivery-summary.md，包含：整体完成情况、所有验收结论、遗留风险、交付物清单。
```

---

## 定期维护（按需触发）

```
读取 AGENTS.md 和 tasks/task-maintenance-template.md，执行一次项目维护任务，检查过时文档、清理技术债、校准 STATE.md。
```

---

## 新迭代开始（上一版本已交付，新需求进来）

```
读取 PRD.md、STATE.md 和 docs/change-log.md，了解当前项目状态。
新需求如下：
{在此描述新需求}

请执行：
1. 评估新需求对现有任务的影响（哪些任务受影响、哪些作废）
2. 更新 PRD.md（旧内容标注"已完成"，新增需求追加到对应章节）
3. 在 docs/change-log.md 记录本次变更
4. 按 tasks/task-template.md 格式生成新任务文件，更新 tasks/README.md
5. 更新 STATE.md
```

> 生成后人工确认影响范围和新任务列表，再执行 Step 4 触发语。

---

## 阻塞解除后重启任务

```
读取 workspace/blocked-{task-id}-{date}.md 和 STATE.md，
了解阻塞原因和人工处理结果，将永久修复落实到对应 docs/ 文件，
然后重新执行 tasks/task-{id}.md。
```

---

## 上下文重置后恢复任务

> AI 提示上下文接近限制后，开新会话使用此触发语。
> 原理：上下文重置（Reset）而非压缩，清空历史，用文件完整交接状态。

```
读取 AGENTS.md、STATE.md 和 tasks/task-{id}.md，继续执行未完成的任务。
STATE.md 中已记录上次的进度和遗留问题，从断点继续，不要重复已完成的步骤。
workspace/sprint-contract-{id}.md 中有已确认的合同，严格按合同范围执行。
```

---

## Initializer：生成 feature_list.json

> 在 Planner 完成后执行，把产品规格转化为机器可读的功能清单。
> AI 后续读取此文件判断做什么、标记完成，比 Markdown 更精确。

```
读取 docs/product-spec.md 和 tasks/task-template.md。

请生成 tasks/feature_list.json，格式如下：
[
  {
    "id": "feature-{三位数}",
    "category": "functional / ui / api / data",
    "priority": "high / medium / low",
    "description": "功能描述，一句话",
    "steps": [
      "验收步骤1（可操作的具体行为）",
      "验收步骤2",
      "验收步骤3"
    ],
    "passes": false,
    "sprint": "task-{id}",
    "notes": ""
  }
]

要求：
- 每个功能独立可验收
- steps 必须是具体可执行的操作步骤，不接受模糊描述
- passes 初始全部为 false
- 所有功能必须映射到对应的 sprint task
```

> 生成后人工检查功能是否完整，再进入 Sprint 合同谈判。

---

## Evaluator 四维评分（界面/创意类项目）

> 适用于有 UI 的项目。替代或补充 Step 4 验证中的 Yes/No 验收。
> 权重设计：设计质量和原创性权重更高，因为 AI 在这两个维度默认表现差。

```
你是 Evaluator Agent，使用四维度评分体系评估本次 Sprint 交付物。

读取 workspace/sprint-contract-{id}.md 的验收标准。

如果环境支持 Chrome DevTools MCP 或 Playwright：
  真正打开页面、点击交互、截图分析，不接受静态代码审查。

按以下四个维度独立打分（每项 1-10 分）：

1. 设计质量（权重 35%）
   - 整体视觉连贯性
   - 是否有清晰的设计语言
   - 氛围与功能是否匹配
   - 扣分项：布局混乱、风格不统一

2. 原创性（权重 30%）
   - 是否有定制化决策，而非套模板
   - 主动惩罚以下"AI 审美惰性"特征：
     紫色渐变、白色卡片堆叠、过度使用 Hero 区域、
     默认 Bootstrap 风格、千篇一律的 SaaS 落地页布局
   - 奖励：有辨识度的视觉决策、意外但合理的创意

3. 工艺水准（权重 20%）
   - 排版、间距、对比度
   - 响应式布局
   - 动画和交互细节

4. 功能性（权重 15%）
   - 核心功能是否可用
   - 是否有明显 Bug
   - 独立于美学评估

输出格式：
## 四维评分报告

| 维度 | 得分 | 权重 | 加权分 | 主要问题 |
|------|------|------|--------|---------|
| 设计质量 | /10 | 35% | | |
| 原创性 | /10 | 30% | | |
| 工艺水准 | /10 | 20% | | |
| 功能性 | /10 | 15% | | |
| **综合得分** | | 100% | **/10** | |

## 具体问题（按优先级）
1.
2.
3.

## 建议方向
- 继续打磨当前方案 / 整体转向（二选一，说明理由）

## 需要 Generator 本轮修复的问题
（列出必须修复的，非建议性的）
```

> 综合得分 7 分以上可关闭 Sprint，低于 7 分必须继续迭代。
