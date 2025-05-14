# Задача 3: Проверка диска

## Использованные команды
Windows аналоги команд `df -h` и `du -sh *`:
```powershell
# Для проверки свободного места на дисках (аналог df -h)
Get-PSDrive -PSProvider 'FileSystem' | Select-Object Name, Used, Free, @{Name='UsedGB';Expression={[math]::Round($_.Used/1GB, 2)}}, @{Name='FreeGB';Expression={[math]::Round($_.Free/1GB, 2)}}, @{Name='TotalGB';Expression={[math]::Round(($_.Used+$_.Free)/1GB, 2)}}

# Для поиска крупных папок (аналог du -sh *)
Get-ChildItem -Path 'C:\Program Files' -Directory | ForEach-Object { $size = (Get-ChildItem -Path $_.FullName -Recurse -File -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; [PSCustomObject]@{Name=$_.Name; SizeMB=[math]::Round($size/1MB, 2)} } | Sort-Object -Property SizeMB -Descending | Select-Object -First 5
```

## Результаты

### Информация о дисках:

| Диск | Использовано (ГБ) | Свободно (ГБ) | Всего (ГБ) |
|------|-------------------|---------------|-----------|
| C: | 456,55 | 9,52 | 466,07 |
| D: | 10 | 0 | 10 |

### Крупнейшие папки:
*Информация будет дополнена.*

## Вывод
Диск C: заполнен на 98%, свободно всего 9,52 ГБ из 466,07 ГБ. Диск D: полностью заполнен. Рекомендуется очистить диски для улучшения производительности системы, особенно диск D:, на котором не осталось свободного места.