# Task-Maintenance：定期维护

> 此模板用于定期触发项目维护任务。
> 建议每 2 周执行一次，或在项目阶段切换时执行。
> 复制此文件，重命名为 task-{编号}-maintenance.md。

---

## 背景（来自 spec）
随着项目推进，文档会过时、技术债会积累、STATE.md 会失真。
此任务让 AI 对项目进行一次系统性自我检查和清理。

## 目标
项目文档与实际代码状态一致，技术债清单最新，STATE.md 准确反映当前进度。

## 输入
- 文件：所有 docs/、tasks/、reports/、src/
- 依赖任务：无（独立执行）
- 外部数据：无

## 输出
- 文档：docs/ 中过时内容更新
- 文档：docs/technical-debt/README.md 更新
- 文档：STATE.md 更新
- 报告：reports/report-maintenance-{date}.md

## 步骤

### 1. 文档审查
- 逐一检查 docs/ 下所有文件
- 标记与当前 src/ 代码不一致的描述
- 更新或删除过时内容
- 在报告中列出所有变更

### 2. 任务清理
- 检查 tasks/ 中所有任务状态
- 确认已完成任务标记为"已完成"
- 识别长期阻塞任务，在报告中说明原因

### 3. 技术债扫描
- 扫描 src/ 中的 TODO / FIXME 注释
- 检查 docs/technical-debt/README.md 是否反映实际情况
- 新增发现的技术债，更新优先级

### 4. STATE.md 校准
- 对照实际任务完成情况，校准整体进度
- 更新遗留问题列表
- 清除已解决的风险项

### 5. 日志归档（可选）
- 将 30 天前的日志移至 logs/archive/

## 验收标准（可执行）
```bash
# 检查 STATE.md 最后更新日期为今天
head -5 STATE.md

# 检查 technical-debt 已更新
cat docs/technical-debt/README.md

# 确认报告已生成
ls reports/ | grep maintenance
```

## 风险
- 文档更新可能引入新的不一致：更新后需人工确认关键文档

## 回滚方案
```bash
git revert HEAD
```

## 优先级
中

## 状态
待处理
