# scripts/ 说明

## 启动脚本（推荐每次开始工作时运行）

### start.bat
每次打开项目时双击运行，自动完成 5 件事：

| 步骤 | 内容 | 说明 |
|------|------|------|
| 1 | 检查并安装 pre-commit hook | 首次自动装，之后跳过 |
| 2 | git pull 同步最新代码 | 无远程仓库则跳过 |
| 3 | 显示 STATE.md 摘要 | 立刻知道项目状态 |
| 4 | 显示待处理任务列表 | 知道今天要做什么 |
| 5 | 运行后台维护 | 同一天只跑一次 |

**使用方式：** 双击 `scripts\start.bat`，或在终端运行：
```cmd
scripts\start.bat
```

---

## 后台维护程序

### harness_maintenance.py
扫描项目文件，调用 NVIDIA NIM Qwen3.5 生成维护报告。

**模型：** `qwen/qwen3.5-35b-a3b`（免费，速度快）

**首次设置：**
```cmd
:: 获取免费 API Key：https://build.nvidia.com/
setx NVIDIA_API_KEY 你的密钥
```

**手动运行：**
```cmd
python scripts\harness_maintenance.py
```

**报告位置：** `reports\maintenance-{YYYY-MM-DD}.md`

---

### setup_maintenance_scheduler.bat
可选：安装开机自动运行任务。
如果你更喜欢手动通过 start.bat 触发，不需要运行此脚本。
