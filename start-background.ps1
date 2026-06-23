$ROOT = "d:\TwinMind"
$LOCAL = "$ROOT\.local"
$PG_BIN = "$LOCAL\pgsql\bin"
$PG_DATA = "$LOCAL\pgsql\data"
$PG_LOG = "$LOCAL\pgsql\postgres.log"
$REDIS_EXE = "$LOCAL\redis\redis-server.exe"
$REDIS_CONF = "$LOCAL\redis\redis.windows.conf"

$env:PGPASSWORD = "postgres123"

# 1. Start Postgres
Start-Process -FilePath "$PG_BIN\pg_ctl.exe" -ArgumentList "-D `"$PG_DATA`" -l `"$PG_LOG`" start" -WindowStyle Hidden
Start-Sleep -Seconds 3

# 2. Start Redis
Start-Process -FilePath $REDIS_EXE -ArgumentList $REDIS_CONF -WindowStyle Hidden
Start-Sleep -Seconds 2

# 3. Start AI Service
Start-Process -FilePath "$ROOT\ai-service\.venv\Scripts\python.exe" -ArgumentList "app.py" -WorkingDirectory "$ROOT\ai-service" -WindowStyle Hidden
Start-Sleep -Seconds 2

# 4. Start Backend
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -WorkingDirectory "$ROOT\backend" -WindowStyle Hidden
Start-Sleep -Seconds 3

# 5. Start Frontend
Start-Process -FilePath "cmd.exe" -ArgumentList "/c npm run dev" -WorkingDirectory "$ROOT\frontend" -WindowStyle Hidden
Start-Sleep -Seconds 3

Write-Host "All background services started successfully."
