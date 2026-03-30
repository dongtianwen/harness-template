# scripts/start.ps1
$ErrorActionPreference = "Continue"

# Project root
$ProjectRoot = (Get-Item (Join-Path $PSScriptRoot "..")).FullName
Push-Location $ProjectRoot

Write-Host "`n === Harness Starting ===" -ForegroundColor Cyan
Write-Host " Project: $ProjectRoot`n"

# 1. pre-commit hook
$HookPath = Join-Path $ProjectRoot ".git\hooks\pre-commit"
$SourceHook = Join-Path $ProjectRoot "bootstrap\hooks\pre-commit"

if (-not (Test-Path $HookPath)) {
    if (Test-Path (Join-Path $ProjectRoot ".git")) {
        Write-Host "[1/5] Installing pre-commit hook..."
        Copy-Item $SourceHook $HookPath -Force
        git config core.fileMode false 2>$null
        Write-Host "     Installed"
    } else {
        Write-Host "[1/5] Initializing git..."
        git init -q
        Copy-Item $SourceHook $HookPath -Force
        Write-Host "     Initialized"
    }
} else {
    Write-Host "[1/5] pre-commit hook ... OK"
}

# 2. git pull
Write-Host "[2/5] Syncing code..."
git pull --quiet 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "     Synced"
} else {
    Write-Host "     Skip (no remote or network issue)"
}

# 3. STATE.md
Write-Host "`n[3/5] Project Status:"
$StateFile = Join-Path $ProjectRoot "STATE.md"
if (Test-Path $StateFile) {
    $stateLines = Get-Content $StateFile -TotalCount 20 -Encoding UTF8
    foreach ($line in $stateLines) {
        Write-Host "     $line"
    }
} else {
    Write-Host "     STATE.md not found" -ForegroundColor Yellow
}

# 4. Pending Tasks
Write-Host "`n[4/5] Pending Tasks:"
$TasksDir = Join-Path $ProjectRoot "tasks"
$taskCount = 0
if (Test-Path $TasksDir) {
    $allTasks = Get-ChildItem -Path $TasksDir -Filter "task-*.md"
    foreach ($tf in $allTasks) {
        if ($tf.Name -match '^task-\d{3}\.md$') {
            $taskContent = Get-Content $tf.FullName -Raw -Encoding UTF8
            if ($taskContent -match "\u5F85\u5904\u7406") { # Matches "待处理"
                Write-Host "     $($tf.BaseName)"
                $taskCount = $taskCount + 1
            }
        }
    }
}
if ($taskCount -eq 0) {
    Write-Host "     No pending tasks"
}

# 5. Maintenance
Write-Host "`n[5/5] Maintenance check..."
$MaintenanceScript = Join-Path $ProjectRoot "scripts\harness_maintenance.py"
$jobObj = Start-Job -ScriptBlock { python $args[0] $args[1] } -ArgumentList $MaintenanceScript, $ProjectRoot

$waitJobRes = Wait-Job $jobObj -Timeout 15
if ($null -eq $waitJobRes) {
    $null = Stop-Job $jobObj
    Write-Host "     Maintenance timed out, skipped" -ForegroundColor Yellow
} else {
    $null = Receive-Job $jobObj
    $todayDate = Get-Date -Format "yyyy-MM-dd"
    $mReportPath = Join-Path $ProjectRoot "reports\maintenance-$todayDate.md"
    if (Test-Path $mReportPath) {
        Write-Host "     Report generated: reports\maintenance-$todayDate.md"
    } else {
        Write-Host "     Check completed"
    }
}

Write-Host "`n === Initialization Complete! ===" -ForegroundColor Green
Write-Host " Tips: Check PROMPTS.md for triggers"
Write-Host " Tips: Check latest repo reports if available`n"

Pop-Location
