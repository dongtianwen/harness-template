@echo off
:: Harness 后台维护程序 - 开机自动运行安装脚本
:: 以管理员身份运行

echo.
echo ============================================
echo  Harness 后台维护程序 - 开机自动运行安装
echo ============================================
echo.

:: 检查管理员权限
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo X 请以管理员身份运行此脚本
    echo   右键点击此文件 → 以管理员身份运行
    pause
    exit /b 1
)

:: 检查 Python
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo X 未找到 Python，请先安装 Python
    pause
    exit /b 1
)

:: 获取路径
set PROJECT_ROOT=%~dp0..
for %%i in ("%PROJECT_ROOT%") do set PROJECT_ROOT=%%~fi
set SCRIPT_PATH=%PROJECT_ROOT%\scripts\harness_maintenance.py
set TASK_NAME=HarnessMaintenance-%RANDOM%

:: 设置 NVIDIA API Key
if "%NVIDIA_API_KEY%"=="" (
    echo.
    echo 未检测到 NVIDIA_API_KEY 环境变量
    echo 获取免费 API Key：https://build.nvidia.com/
    echo.
    set /p API_KEY=请输入你的 NVIDIA API Key（直接回车跳过）: 
    if not "%API_KEY%"=="" (
        setx NVIDIA_API_KEY "%API_KEY%" /M
        echo API Key 已保存到系统环境变量
    )
)

:: 删除同项目的旧任务
for /f "tokens=*" %%a in ('schtasks /query /fo LIST 2^>nul ^| findstr "HarnessMaintenance"') do (
    schtasks /delete /tn "%%a" /f >nul 2>&1
)

:: 创建开机触发任务（登录后延迟2分钟运行）
schtasks /create /tn "HarnessMaintenance" ^
    /tr "python \"%SCRIPT_PATH%\" \"%PROJECT_ROOT%\"" ^
    /sc ONLOGON ^
    /delay 0002:00 ^
    /ru "%USERNAME%" ^
    /f

if %errorLevel% equ 0 (
    echo.
    echo 安装成功
    echo.
    echo 运行规则：
    echo   触发：每次登录系统时，延迟 2 分钟运行
    echo   频率：同一天内只运行一次，不会重复
    echo   报告：%PROJECT_ROOT%\reports\maintenance-日期.md
    echo.
    echo 立即手动测试：
    echo   python "%SCRIPT_PATH%" "%PROJECT_ROOT%"
    echo.
    echo 删除此任务：
    echo   schtasks /delete /tn "HarnessMaintenance" /f
) else (
    echo 安装失败，请检查权限
)

pause