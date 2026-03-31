"""
Harness 后台维护程序 (官方向量版)
- 扫描项目状态，通过智谱官方 glm-4.7-flash 生成维护报告
- 自动绕过环境变量中可能存在的无效占位符
- 报告输出到 reports/maintenance-{date}.md
"""

import os
import sys
import datetime
import json
from pathlib import Path

# 针对 Windows 环境强制使用 UTF-8 输出，确保在控制台环境下也能正确显示中文
if sys.platform == "win32":
    import io
    if hasattr(sys.stdout, 'buffer'):
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8')
    if hasattr(sys.stderr, 'buffer'):
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding='utf-8')

def get_verified_key():
    """
    智能获取 API 密钥：
    1. 优先检查环境变量 ZHIPU_API_KEY
    2. 如果环境变量包含“您的”或为空，则指导用户填入真正的 Key
    """
    key = os.environ.get("ZHIPU_API_KEY")
    # 如果环境中的 key 不合法，则强制提示需要真实 Key
    if not key or "您的" in key or "YOUR_" in key:
        # 这里建议用户通过设置环境变量的方式注入，不再硬编码
        return "YOUR_ZHIPU_API_KEY"
    return key

# ========== 配置 ==========
ZHIPU_API_KEY = get_verified_key()
ZHIPU_API_URL = "https://open.bigmodel.cn/api/paas/v4/chat/completions"
ZHIPU_MODEL = "glm-4.7-flash"
API_TIMEOUT = 25
# ==========================

def call_zhipu_api(prompt):
    """
    使用 httpx 通过字节流模式调用智谱 API，彻底规避 Windows 下的 ASCII 编码异常
    """
    try:
        import httpx
        headers = {
            "Authorization": "Bearer " + ZHIPU_API_KEY,
            "Content-Type": "application/json"
        }
        data = {
            "model": ZHIPU_MODEL,
            "messages": [{"role": "user", "content": prompt}],
            "temperature": 1.0,
            "max_tokens": 1024
        }
        
        # 显式使用 UTF-8 字节流，无视 locale 干扰
        payload_bytes = json.dumps(data, ensure_ascii=False).encode('utf-8')
        
        response = httpx.post(
            ZHIPU_API_URL, 
            headers=headers, 
            content=payload_bytes, 
            timeout=API_TIMEOUT
        )
        
        if response.status_code != 200:
            return "❌ API 响应错误 (" + str(response.status_code) + "): " + response.text
            
        res_json = response.json()
        if "choices" in res_json and len(res_json["choices"]) > 0:
            return res_json["choices"][0]["message"]["content"].strip()
        return "（模型返回内容为空）"
        
    except Exception as e:
        return "❌ API 调用异常: " + str(e)

def collect_context(root):
    """收集项目上下文"""
    ctx = []
    for f in ["STATE.md", "PRD.md"]:
        p = root / f
        if p.exists():
            try:
                # 使用 utf-8 读取，忽略错误
                text = p.read_text(encoding="utf-8", errors="ignore")[:2000]
                ctx.append(f"### {f}\n{text}")
            except:
                pass
    return "\n\n".join(ctx)

def save_report(root, content):
    """保存维护报告"""
    today = datetime.date.today().strftime("%Y-%m-%d")
    path = root / "reports" / ("maintenance-" + today + ".md")
    (root / "reports").mkdir(exist_ok=True)
    
    report_text = f"# 维护报告 - {today}\n\n"
    report_text += f"> 由 Harness 启动脚本自动生成 | 模型：{ZHIPU_MODEL} (Official)\n\n---\n\n"
    report_text += content
    report_text += f"\n\n---\n*生成时间：{datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*\n"
    
    path.write_text(report_text, encoding="utf-8")
    return path

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python harness_maintenance.py <project_root>")
        sys.exit(1)
    
    root_path = Path(sys.argv[1])
    # 构建中文指令
    prompt = "你是 Harness 项目维护 Agent。根据以下项目状态生成简洁中文维护报告。要求包含任务状态、STATE.md 准确性及后续建议：\n\n" + collect_context(root_path)
    
    print("⏳ 正在调用智谱官方 API 生成报告...")
    report_body = call_zhipu_api(prompt)
    report_path = save_report(root_path, report_body)
    print(f"✅ 维护报告已保存在：{report_path}")
