# Skill：项目初始化（harness-setup）

## 触发条件
当任务描述包含以下关键词时自动加载：
- "初始化"、"新项目"、"setup"、"init"、"第一次"

## 用途
确保项目在开始任何任务前，Harness 基础设施已正确安装。

## 工作流程
1. 检查 .git/hooks/pre-commit 是否存在
   - 不存在 → 执行安装：
     ```bash
     cp bootstrap/hooks/pre-commit .git/hooks/pre-commit
     chmod +x .git/hooks/pre-commit
     ```
2. 检查 AGENTS.md 项目上下文是否已填写
   - 未填写 → 提示人工填写项目名称、核心目标、技术栈、项目类型
3. 检查 PRD.md 是否已填写
   - 未填写 → 提示运行架构设计工作流
4. 检查 STATE.md 是否已初始化
   - 未初始化 → 写入初始状态
5. 输出初始化清单确认结果

## 输出格式
```
# 初始化检查结果

- [✅/❌] pre-commit hook 已安装
- [✅/❌] AGENTS.md 项目上下文已填写
- [✅/❌] PRD.md 已填写
- [✅/❌] STATE.md 已初始化

下一步：{具体指引}
```
