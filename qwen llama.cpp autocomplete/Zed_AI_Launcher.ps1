# Точні шляхи до файлів
$zedExe = "C:\Users\S_D\AppData\Local\Programs\Zed\zed.exe"
$llamaExe = "D:\llamacpp\llama-server.exe"
$modelFile = "D:\llamacpp\models\qwen2.5-coder-1.5b-q8_0.gguf"
$serverArgs = "-m `"$modelFile`" -c 4096 -ngl 99 --port 8080 --special"

# 1. Захист від подвійного запуску сервера
$existingServer = Get-Process -Name "llama-server" -ErrorAction SilentlyContinue
if (-not $existingServer) {
    Start-Process -FilePath $llamaExe -ArgumentList $serverArgs -WindowStyle Hidden
}

# 2. Перевіряємо, чи запущений Zed
$zedProcesses = Get-Process -Name "zed" -ErrorAction SilentlyContinue
if (-not $zedProcesses) {
    Start-Process -FilePath $zedExe
    Start-Sleep -Seconds 3
}

# 3. Надійний цикл моніторингу
while (Get-Process -Name "zed" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 2
}

# 4. Примусове очищення VRAM після закриття Zed
$serversToKill = Get-Process -Name "llama-server" -ErrorAction SilentlyContinue
if ($serversToKill) {
    $serversToKill | Stop-Process -Force
}