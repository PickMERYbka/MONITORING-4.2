# Выводы

## Какие команды были полезны?
В ходе выполнения заданий по мониторингу системы в Windows были особенно полезны следующие PowerShell команды:

1. `Get-Process` - позволяет получить информацию о всех запущенных процессах
2. `Get-CimInstance -ClassName Win32_OperatingSystem` - предоставляет системную информацию, включая данные о памяти
3. `Get-PSDrive` - отображает информацию о дисках
4. `Get-ChildItem` - позволяет получить информацию о файлах и папках

## Что нового узнал(а)?
В процессе выполнения заданий узнал(а):
1. Как использовать PowerShell для мониторинга системных ресурсов
2. Как анализировать потребление ресурсов отдельными процессами
3. Как идентифицировать проблемные места в системе (высокая загрузка CPU, низкий объем свободной памяти, заполненность дисков)
4. Как форматировать и сортировать вывод команд PowerShell для получения более наглядной информации

## Как бы я автоматизировал(а) мониторинг?
Для автоматизации мониторинга системы можно:

1. Создать PowerShell-скрипт, который собирает всю необходимую информацию и сохраняет её в лог-файл:
```powershell
# monitor.ps1
$logFile = "C:\monitoring\system_log_$(Get-Date -Format 'yyyy-MM-dd').txt"

# Создаем заголовок с датой и временем
"=== Мониторинг системы: $(Get-Date) ===" | Out-File -FilePath $logFile

# Проверка CPU
"--- Топ 5 процессов по CPU ---" | Out-File -FilePath $logFile -Append
Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 5 Name, CPU, WorkingSet | Out-File -FilePath $logFile -Append

# Проверка памяти
"--- Использование памяти ---" | Out-File -FilePath $logFile -Append
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object FreePhysicalMemory, TotalVisibleMemorySize | 
    ForEach-Object { 'Total Memory: ' + [math]::Round($_.TotalVisibleMemorySize/1MB, 2) + ' GB | Free Memory: ' + [math]::Round($_.FreePhysicalMemory/1MB, 2) + ' GB' } | 
    Out-File -FilePath $logFile -Append

# Проверка дисков
"--- Использование дисков ---" | Out-File -FilePath $logFile -Append
Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, @{Name='UsedGB';Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name='FreeGB';Expression={[math]::Round($_.Free/1GB, 2)}} | 
    Out-File -FilePath $logFile -Append
```

2. Настроить Планировщик заданий Windows для запуска этого скрипта через регулярные интервалы (например, каждый час)

3. Добавить в скрипт проверку критических значений и отправку уведомлений при их превышении (например, если свободное место на диске < 10%, или загрузка CPU > 90% длительное время)

4. Использовать специализированные инструменты мониторинга, такие как:
   - Windows Performance Monitor
   - Zabbix
   - Nagios
   - Grafana + Prometheus

Такой подход позволит автоматически собирать информацию о работе системы, своевременно выявлять проблемы и принимать меры по их устранению.