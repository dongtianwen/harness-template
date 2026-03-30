#!/bin/bash
# Harness v1.0 - 项目初始化脚本
# 用法：bash init-project.sh <项目名>

set -e

PROJECT_NAME=$1
TEMPLATE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

if [ -z "$PROJECT_NAME" ]; then
  echo "❌ 请提供项目名称"
  echo "用法：bash init-project.sh <项目名>"
  exit 1
fi

if [ -d "$PROJECT_NAME" ]; then
  echo "❌ 目录 '$PROJECT_NAME' 已存在，请换一个名称"
  exit 1
fi

echo "🚀 初始化项目：$PROJECT_NAME"

# 复制模板结构
cp -r "$TEMPLATE_DIR" "$PROJECT_NAME"

# 清理不需要复制的文件
rm -rf "$PROJECT_NAME/bootstrap"
rm -f "$PROJECT_NAME/reports/task-001-report.md"

# 替换项目名占位符
TODAY=$(date +%Y-%m-%d)
find "$PROJECT_NAME" -type f -name "*.md" | while read f; do
  sed -i "s/\[项目名称\]/$PROJECT_NAME/g" "$f"
  sed -i "s/YYYY-MM-DD/$TODAY/g" "$f"
done

# 初始化 git
cd "$PROJECT_NAME"
git init -q

# 安装 pre-commit hook
cp "$TEMPLATE_DIR/bootstrap/hooks/pre-commit" .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
echo "  ✅ pre-commit hook 已安装"

git add .
git commit -q -m "init: Harness v1.0 scaffold"

echo ""
echo "✅ 项目初始化完成：$PROJECT_NAME"
echo ""
echo "下一步："
echo "  1. 运行架构设计工作流，生成 PRD"
echo "  2. 填写 PRD.md"
echo "  3. 打开 PROMPTS.md，复制 Step 3 触发语，让 AI 自动拆解任务"
echo "  4. 确认任务列表后，复制 Step 4 触发语开始执行"
