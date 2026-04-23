# Exact file paths
$zedExe = "C:\Users\S_D\AppData\Local\Programs\Zed\zed.exe"
$llamaExe = "D:\llamacpp\llama-server.exe"
$modelFile = "D:\llamacpp\models\qwen2.5-coder-1.5b-q8_0.gguf"
$serverArgs = "-m `"$modelFile`" -c 4096 -ngl 99 --port 8080 --special"

# 1. Protection against double server launch
$existingServer = Get-Process -Name "llama-server" -ErrorAction SilentlyContinue
if (-not $existingServer) {
    Start-Process -FilePath $llamaExe -ArgumentList $serverArgs -WindowStyle Hidden
}

# 2. Check if Zed is running
$zedProcesses = Get-Process -Name "zed" -ErrorAction SilentlyContinue
if (-not $zedProcesses) {
    Start-Process -FilePath $zedExe
    Start-Sleep -Seconds 3
}

# 3. Robust monitoring loop
while (Get-Process -Name "zed" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 2
}

# 4. Force VRAM cleanup after Zed closes
$serversToKill = Get-Process -Name "llama-server" -ErrorAction SilentlyContinue
if ($serversToKill) {
    $serversToKill | Stop-Process -Force
}
