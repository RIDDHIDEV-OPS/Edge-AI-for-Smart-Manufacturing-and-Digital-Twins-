# ============================================================
# TwinMind Platform - Robust Local Startup Script
# ============================================================

$ROOT = $PSScriptRoot
$LOCAL = "$ROOT\.local"
$PG_BIN = "$LOCAL\pgsql\bin"
$PG_DATA = "$LOCAL\pgsql\data"
$PG_LOG = "$LOCAL\pgsql\postgres.log"
$REDIS_EXE = "$LOCAL\redis\redis-server.exe"
$REDIS_CONF = "$LOCAL\redis\redis.windows.conf"

$env:PGPASSWORD = "postgres123"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TwinMind Platform - Starting Up      " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# 1. Start PostgreSQL (Detached)
Write-Host "[1/5] Starting PostgreSQL..." -ForegroundColor Yellow
$pgStatus = & "$PG_BIN\pg_ctl.exe" -D $PG_DATA status 2>&1
if ($pgStatus -match "server is running") {
    Write-Host "      PostgreSQL already running." -ForegroundColor Green
} else {
    Start-Process -FilePath "$PG_BIN\pg_ctl.exe" -ArgumentList "-D `"$PG_DATA`" -l `"$PG_LOG`" start" -WindowStyle Hidden
    Start-Sleep -Seconds 2
    Write-Host "      PostgreSQL started." -ForegroundColor Green
}

# 2. Start Redis (Detached)
Write-Host "[2/5] Starting Redis..." -ForegroundColor Yellow
$redisRunning = Get-Process -Name "redis-server" -ErrorAction SilentlyContinue
if ($redisRunning) {
    Write-Host "      Redis already running." -ForegroundColor Green
} else {
    Start-Process -FilePath $REDIS_EXE -ArgumentList $REDIS_CONF -WindowStyle Hidden
    Start-Sleep -Seconds 1
    Write-Host "      Redis started." -ForegroundColor Green
}

# 3. Start Backend (Visible Window)
Write-Host "[3/5] Starting Backend (port 3001)..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/k", "title TwinMind Backend && cd /d `"$ROOT\backend`" && npm run dev" -WindowStyle Normal

# 4. Start AI Service (Visible Window)
Write-Host "[4/5] Starting AI Service (port 5000)..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/k", "title TwinMind AI Service && cd /d `"$ROOT\ai-service`" && .venv\Scripts\python.exe app.py" -WindowStyle Normal

# 5. Start Frontend (Visible Window)
Write-Host "[5/5] Starting Frontend (port 5173)..." -ForegroundColor Yellow
Start-Process -FilePath "cmd.exe" -ArgumentList "/k", "title TwinMind Frontend && cd /d `"$ROOT\frontend`" && npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   TwinMind Platform - ALL SERVICES UP  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Three new terminal windows have been opened for the services."
Write-Host "To stop the platform later, simply close those 3 windows."
Write-Host "Your frontend is available at: http://localhost:5173" -ForegroundColor Magenta
Write-Host "You can close this window now." -ForegroundColor Gray
