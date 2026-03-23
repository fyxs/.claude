<#
.SYNOPSIS
    Claude 配置集中备份脚本

.DESCRIPTION
    根据 sources.json 配置文件，将多层 Claude 配置备份到集中仓库
    支持 exclude 模式、白名单模式、变更检测

.PARAMETER BackupRoot
    备份目标根目录路径

.PARAMETER SourcesJson
    sources.json 配置文件路径

.PARAMETER DetectChanges
    是否启用变更检测（记录并报告新增/删除的文件）

.PARAMETER IncrementalBackup
    是否增量备份（只复制修改过的文件）

.EXAMPLE
    .\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config"

.EXAMPLE
    .\sync-backup.ps1 -BackupRoot "D:\10Backups\Claude-Config" -DetectChanges -IncrementalBackup
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupRoot,

    [Parameter(Mandatory=$false)]
    [string]$SourcesJson = "C:\Users\admin\.claude\scripts\sync-backup\sources.json",

    [Parameter(Mandatory=$false)]
    [switch]$DetectChanges,

    [Parameter(Mandatory=$false)]
    [switch]$IncrementalBackup
)

$ErrorActionPreference = "Stop"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Read-SourcesConfig {
    param([string]$Path)

    if (-not (Test-Path $Path)) {
        throw "配置文件不存在: $Path"
    }

    try {
        $config = Get-Content $Path -Raw -Encoding UTF8 | ConvertFrom-Json
        return $config
    }
    catch {
        throw "配置文件解析失败: $_"
    }
}

function Backup-ClaudeDirectory {
    param(
        [string]$Source,
        [string]$Target,
        [string]$Mode,
        [array]$ExcludeList,
        [bool]$Incremental
    )

    Write-ColorOutput "  备份 .claude 目录: $Source" "Cyan"
    Write-ColorOutput "  模式: $Mode" "Gray"

    if (-not (Test-Path $Source)) {
        Write-ColorOutput "  [警告] 源目录不存在，跳过" "Yellow"
        return @{
            Success = $false
            FileCount = 0
            TotalSize = 0
        }
    }

    if (-not (Test-Path $Target)) {
        New-Item -ItemType Directory -Path $Target -Force | Out-Null
    }

    $fileCount = 0
    $totalSize = 0

    if ($Mode -eq "exclude") {
        $allItems = Get-ChildItem -Path $Source -Recurse -Force

        foreach ($item in $allItems) {
            $relativePath = $item.FullName.Substring($Source.Length).TrimStart('\')

            $shouldExclude = $false
            foreach ($excludePattern in $ExcludeList) {
                if ($relativePath -like "$excludePattern*" -or $relativePath -eq $excludePattern) {
                    $shouldExclude = $true
                    break
                }
            }

            if ($shouldExclude) {
                continue
            }

            $targetPath = Join-Path $Target $relativePath

            if ($item.PSIsContainer) {
                if (-not (Test-Path $targetPath)) {
                    New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
                }
            }
            else {
                $shouldCopy = $true

                if ($Incremental -and (Test-Path $targetPath)) {
                    $sourceTime = $item.LastWriteTime
                    $targetTime = (Get-Item $targetPath).LastWriteTime

                    if ($sourceTime -le $targetTime) {
                        $shouldCopy = $false
                    }
                }

                if ($shouldCopy) {
                    $targetDir = Split-Path $targetPath -Parent
                    if (-not (Test-Path $targetDir)) {
                        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                    }

                    Copy-Item -Path $item.FullName -Destination $targetPath -Force
                    $fileCount++
                    $totalSize += $item.Length
                }
            }
        }
    }
    elseif ($Mode -eq "all") {
        Copy-Item -Path "$Source\*" -Destination $Target -Recurse -Force
        $allFiles = Get-ChildItem -Path $Target -Recurse -File
        $fileCount = $allFiles.Count
        $totalSize = ($allFiles | Measure-Object -Property Length -Sum).Sum
    }

    Write-ColorOutput "  [完成] $fileCount 个文件, $([math]::Round($totalSize/1MB, 2)) MB" "Green"

    return @{
        Success = $true
        FileCount = $fileCount
        TotalSize = $totalSize
    }
}

function Backup-AuxiliaryAssets {
    param(
        [array]$Assets,
        [string]$BaseTargetPath,
        [bool]$Incremental
    )

    Write-ColorOutput "  备份辅助资产" "Cyan"

    $fileCount = 0
    $totalSize = 0

    foreach ($asset in $Assets) {
        $source = $asset.source
        $target = Join-Path $BaseTargetPath $asset.target

        if (-not (Test-Path $source)) {
            Write-ColorOutput "  [警告] 源不存在: $source" "Yellow"
            continue
        }

        $sourceItem = Get-Item $source

        if ($sourceItem.PSIsContainer) {
            Write-ColorOutput "    [目录] $source" "Gray"

            $targetDir = $target
            if (-not (Test-Path $targetDir)) {
                New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
            }

            $items = Get-ChildItem -Path $source -Recurse -File
            foreach ($item in $items) {
                $relativePath = $item.FullName.Substring($source.Length).TrimStart('\')
                $targetPath = Join-Path $targetDir $relativePath

                $shouldCopy = $true
                if ($Incremental -and (Test-Path $targetPath)) {
                    $sourceTime = $item.LastWriteTime
                    $targetTime = (Get-Item $targetPath).LastWriteTime
                    if ($sourceTime -le $targetTime) {
                        $shouldCopy = $false
                    }
                }

                if ($shouldCopy) {
                    $targetParent = Split-Path $targetPath -Parent
                    if (-not (Test-Path $targetParent)) {
                        New-Item -ItemType Directory -Path $targetParent -Force | Out-Null
                    }
                    Copy-Item -Path $item.FullName -Destination $targetPath -Force
                    $fileCount++
                    $totalSize += $item.Length
                }
            }
        }
        else {
            Write-ColorOutput "    [文件] $source" "Gray"

            $shouldCopy = $true
            if ($Incremental -and (Test-Path $target)) {
                $sourceTime = $sourceItem.LastWriteTime
                $targetTime = (Get-Item $target).LastWriteTime
                if ($sourceTime -le $targetTime) {
                    $shouldCopy = $false
                }
            }

            if ($shouldCopy) {
                $targetDir = Split-Path $target -Parent
                if (-not (Test-Path $targetDir)) {
                    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
                }
                Copy-Item -Path $source -Destination $target -Force
                $fileCount++
                $totalSize += $sourceItem.Length
            }
        }
    }

    Write-ColorOutput "  [完成] $fileCount 个文件, $([math]::Round($totalSize/1MB, 2)) MB" "Green"

    return @{
        Success = $true
        FileCount = $fileCount
        TotalSize = $totalSize
    }
}

function Generate-FileManifest {
    param([string]$RootPath)

    $manifest = @{}

    if (Test-Path $RootPath) {
        $files = Get-ChildItem -Path $RootPath -Recurse -File
        foreach ($file in $files) {
            $relativePath = $file.FullName.Substring($RootPath.Length).TrimStart('\')
            $manifest[$relativePath] = @{
                Size = $file.Length
                LastWriteTime = $file.LastWriteTime.ToString("o")
            }
        }
    }

    return $manifest
}

function Detect-FileChanges {
    param(
        [hashtable]$CurrentManifest,
        [hashtable]$PreviousManifest
    )

    $changes = @{
        Added = @()
        Removed = @()
        Modified = @()
    }

    foreach ($file in $CurrentManifest.Keys) {
        if (-not $PreviousManifest.ContainsKey($file)) {
            $changes.Added += $file
        }
        elseif ($CurrentManifest[$file].LastWriteTime -ne $PreviousManifest[$file].LastWriteTime) {
            $changes.Modified += $file
        }
    }

    foreach ($file in $PreviousManifest.Keys) {
        if (-not $CurrentManifest.ContainsKey($file)) {
            $changes.Removed += $file
        }
    }

    return $changes
}

function Main {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "Claude 配置集中备份" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"

    Write-ColorOutput "[读取] 配置文件: $SourcesJson" "White"
    $config = Read-SourcesConfig -Path $SourcesJson
    Write-ColorOutput "[成功] 配置加载成功`n" "Green"

    if (-not (Test-Path $BackupRoot)) {
        Write-ColorOutput "[创建] 备份根目录: $BackupRoot" "White"
        New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
    }

    $totalStats = @{
        FileCount = 0
        TotalSize = 0
    }

    Write-ColorOutput "[全局层] 开始备份" "Yellow"
    $globalConfig = $config.layers.global

    $result = Backup-ClaudeDirectory `
        -Source $globalConfig.claudeDirBackup.source `
        -Target (Join-Path $BackupRoot $globalConfig.claudeDirBackup.target) `
        -Mode $globalConfig.claudeDirBackup.mode `
        -ExcludeList $globalConfig.claudeDirBackup.exclude `
        -Incremental $IncrementalBackup

    $totalStats.FileCount += $result.FileCount
    $totalStats.TotalSize += $result.TotalSize

    if ($globalConfig.auxiliaryAssets) {
        $result = Backup-AuxiliaryAssets `
            -Assets $globalConfig.auxiliaryAssets `
            -BaseTargetPath $BackupRoot `
            -Incremental $IncrementalBackup

        $totalStats.FileCount += $result.FileCount
        $totalStats.TotalSize += $result.TotalSize
    }

    Write-ColorOutput ""

    foreach ($domainName in $config.layers.domains.PSObject.Properties.Name) {
        Write-ColorOutput "[领域层: $domainName] 开始备份" "Yellow"
        $domainConfig = $config.layers.domains.$domainName

        $result = Backup-ClaudeDirectory `
            -Source $domainConfig.claudeDirBackup.source `
            -Target (Join-Path $BackupRoot $domainConfig.claudeDirBackup.target) `
            -Mode $domainConfig.claudeDirBackup.mode `
            -ExcludeList $domainConfig.claudeDirBackup.exclude `
            -Incremental $IncrementalBackup

        $totalStats.FileCount += $result.FileCount
        $totalStats.TotalSize += $result.TotalSize

        if ($domainConfig.auxiliaryAssets) {
            $result = Backup-AuxiliaryAssets `
                -Assets $domainConfig.auxiliaryAssets `
                -BaseTargetPath $BackupRoot `
                -Incremental $IncrementalBackup

            $totalStats.FileCount += $result.FileCount
            $totalStats.TotalSize += $result.TotalSize
        }

        Write-ColorOutput ""
    }

    if ($DetectChanges) {
        Write-ColorOutput "[变更检测] 分析文件变更" "Yellow"

        $manifestPath = Join-Path $BackupRoot ".backup-manifest.json"
        $currentManifest = Generate-FileManifest -RootPath $BackupRoot

        if (Test-Path $manifestPath) {
            $previousManifest = Get-Content $manifestPath -Raw | ConvertFrom-Json -AsHashtable
            $changes = Detect-FileChanges -CurrentManifest $currentManifest -PreviousManifest $previousManifest

            if ($changes.Added.Count -gt 0) {
                Write-ColorOutput "  [新增] $($changes.Added.Count) 个文件" "Green"
                foreach ($file in $changes.Added) {
                    Write-ColorOutput "     $file" "Gray"
                }
            }

            if ($changes.Removed.Count -gt 0) {
                Write-ColorOutput "  [删除] $($changes.Removed.Count) 个文件" "Red"
                foreach ($file in $changes.Removed) {
                    Write-ColorOutput "     $file" "Gray"
                }
            }

            if ($changes.Modified.Count -gt 0) {
                Write-ColorOutput "  [修改] $($changes.Modified.Count) 个文件" "Cyan"
                foreach ($file in $changes.Modified) {
                    Write-ColorOutput "     $file" "Gray"
                }
            }

            if ($changes.Added.Count -eq 0 -and $changes.Removed.Count -eq 0 -and $changes.Modified.Count -eq 0) {
                Write-ColorOutput "  [无变更]" "Green"
            }
        }
        else {
            Write-ColorOutput "  [信息] 首次备份，无历史清单" "Gray"
        }

        $currentManifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath -Encoding UTF8
        Write-ColorOutput ""
    }

    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "[完成] 备份完成" "Green"
    Write-ColorOutput "========================================" "Cyan"
    Write-ColorOutput "[统计] 文件数量: $($totalStats.FileCount)" "White"
    Write-ColorOutput "[统计] 总大小: $([math]::Round($totalStats.TotalSize/1MB, 2)) MB" "White"
    Write-ColorOutput "[统计] 备份位置: $BackupRoot" "White"
    Write-ColorOutput ""
}

try {
    Main
}
catch {
    Write-ColorOutput "`n[错误] 备份失败: $_" "Red"
    Write-ColorOutput $_.ScriptStackTrace "Red"
    exit 1
}
