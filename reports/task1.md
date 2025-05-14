# Задача 1: Мониторинг загрузки системы

## Использованные команды
Windows аналоги команд `top` и `free -h`:
```powershell
# Для проверки загрузки процессора (аналог top)
Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10 Name, CPU, WorkingSet

# Для проверки использования памяти (аналог free -h)
Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object FreePhysicalMemory, TotalVisibleMemorySize | ForEach-Object { 'Total Memory: ' + [math]::Round($_.TotalVisibleMemorySize/1MB, 2) + ' GB | Free Memory: ' + [math]::Round($_.FreePhysicalMemory/1MB, 2) + ' GB' }
```

## Результаты

### Топ 10 процессов по использованию CPU:

| Name | CPU | WorkingSet (байт) |
|------|-----|------------------|
| explorer | 1469,953125 | 185249792 |
| Telegram | 1234,28125 | 352301056 |
| chrome | 1188,4375 | 197070848 |
| chrome | 923,90625 | 93536256 |
| studio64 | 647,078125 | 1197400064 |
| qemu-system-x86_64 | 605,390625 | 1177198592 |
| java | 424,21875 | 718606336 |
| ctfmon | 343,125 | 15224832 |
| svchost | 255,5 | 22843392 |
| nvcontainer | 219,875 | 63660032 |

### Использование памяти:
Total Memory: 15.71 GB | Free Memory: 0.83 GB

## Вывод
Система испытывает значительную нагрузку на процессор, наибольшее потребление ресурсов CPU приходится на приложения Explorer, Telegram и Chrome. Также система использует значительное количество оперативной памяти - свободно всего 0.83 ГБ из 15.71 ГБ.