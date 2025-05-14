# Monitor-System.ps1
# Скрипт для мониторинга основных системных показателей

# Определяем путь для лог-файла
$logFolder = "$env:USERPROFILE\Documents\SystemMonitoring"
$logFile = "$logFolder\system_log_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Создаем папку для логов, если она не существует
if (!(Test-Path -Path $logFolder)) {
    New-Item -ItemType Directory -Path $logFolder | Out-Null
}

# Функция для записи информации в лог
function Write-Log {
    param (
        [string]$Message
    )
    
    "$Message" | Out-File -FilePath $logFile -Append
}

# Заголовок с датой и временем
Write-Log "=== Мониторинг системы: $(Get-Date) ==="
Write-Log ""

# 1. Проверка CPU
Write-Log "--- Топ 5 процессов по CPU ---"
$cpuProcesses = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5 Name, CPU, WorkingSet, @{Name='Memory(MB)';Expression={[math]::Round($_.WorkingSet / 1MB, 2)}}
$cpuProcesses | Format-Table -AutoSize | Out-String | Write-Log

# Общая загрузка CPU
$cpuLoad = (Get-CimInstance -ClassName Win32_Processor | Measure-Object -Property LoadPercentage -Average).Average
Write-Log "Общая загрузка CPU: $cpuLoad%"
Write-Log ""

# 2. Проверка памяти
Write-Log "--- Использование памяти ---"
$memory = Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object @{Name='TotalMemory(GB)';Expression={[math]::Round($_.TotalVisibleMemorySize/1MB, 2)}}, @{Name='FreeMemory(GB)';Expression={[math]::Round($_.FreePhysicalMemory/1MB, 2)}}, @{Name='MemoryUsed(%)';Expression={[math]::Round((($_.TotalVisibleMemorySize - $_.FreePhysicalMemory) / $_.TotalVisibleMemorySize * 100), 2)}}
$memory | Format-Table -AutoSize | Out-String | Write-Log
Write-Log ""

# 3. Проверка дисков
Write-Log "--- Использование дисков ---"
$disks = Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name='UsedGB';Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name='FreeGB';Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name='TotalGB';Expression={[math]::Round(($_.Used+$_.Free)/1GB, 2)}}, @{Name='UsedPercent';Expression={[math]::Round($_.Used/($_.Used+$_.Free) * 100, 2)}}
$disks | Format-Table -AutoSize | Out-String | Write-Log
Write-Log ""

# 4. Проверка сетевых подключений
Write-Log "--- Активные сетевые подключения ---"
$networkConnections = Get-NetTCPConnection -State Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, State, @{Name='ProcessName';Expression={(Get-Process -Id $_.OwningProcess).Name}} | Sort-Object ProcessName 
$networkConnections | Format-Table -AutoSize | Out-String | Write-Log
Write-Log ""

# 5. Проверка запущенных служб
Write-Log "--- Остановленные службы, которые должны быть запущены ---"
$services = Get-Service | Where-Object {$_.StartType -eq 'Automatic' -and $_.Status -ne 'Running'}
$services | Format-Table Name, DisplayName, Status, StartType -AutoSize | Out-String | Write-Log
Write-Log ""

# Заключение и рекомендации
Write-Log "=== Рекомендации ==="
# Предупреждения по CPU
if ($cpuLoad -gt 80) {
    Write-Log "ВНИМАНИЕ: Высокая загрузка CPU ($cpuLoad%). Рекомендуется проверить процессы с высоким потреблением."
}

# Предупреждения по памяти
if ($memory.'MemoryUsed(%)' -gt 90) {
    Write-Log "ВНИМАНИЕ: Высокое использование памяти ($($memory.'MemoryUsed(%)') %). Рекомендуется закрыть неиспользуемые приложения."
}

# Предупреждения по дискам
foreach ($disk in $disks) {
    if ($disk.UsedPercent -gt 90) {
        Write-Log "ВНИМАНИЕ: Диск $($disk.Name): заполнен на $($disk.UsedPercent)%. Рекомендуется очистить диск."
    }
}

# Вывод информации в консоль
Write-Host "Мониторинг системы выполнен. Результаты сохранены в $logFile" -ForegroundColor Green

# На будущее: можно добавить отправку отчета по email при критических показателях
# Send-MailMessage -To "admin@example.com" -From "monitoring@example.com" -Subject "Системное предупреждение" -Body "Проверьте отчет о мониторинге" -Attachments $logFile -SmtpServer "smtp.example.com"