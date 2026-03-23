param(
    [Parameter(Mandatory=$true)]
    [string]$BackupRoot,
    [Parameter(Mandatory=$false)]
    [string]$SourcesJson = "C:\Users\admin\.claude\scripts\sync-backup\sources.json"
)

$ErrorActionPreference = "Stop"

function Backup-WithExclude {
    param([string]$Source, [string]$Target, [array]$Exclude)

    if (-not (Test-Path $Source)) { return 0 }
    if (-not (Test-Path $Target)) { New-Item -ItemType Directory -Path $Target -Force | Out-Null }

    $count = 0
    $items = Get-ChildItem -Path $Source -Recurse -Force

    foreach ($item in $items) {
        $relPath = $item.FullName.Substring($Source.Length).TrimStart('\')
        $shouldExclude = $false
        foreach ($pattern in $Exclude) {
            if ($relPath -like "$pattern*" -or $relPath -eq $pattern) {
                $shouldExclude = $true
                break
            }
        }
        if ($shouldExclude) { continue }

        $targetPath = Join-Path $Target $relPath
        if ($item.PSIsContainer) {
            if (-not (Test-Path $targetPath)) { New-Item -ItemType Directory -Path $targetPath -Force | Out-Null }
        } else {
            $targetDir = Split-Path $targetPath -Parent
            if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
            Copy-Item -Path $item.FullName -Destination $targetPath -Force
            $count++
        }
    }
    return $count
}

function Backup-Assets {
    param([array]$Assets, [string]$BaseTarget)

    $count = 0
    foreach ($asset in $Assets) {
        if (-not (Test-Path $asset.source)) { continue }
        $target = Join-Path $BaseTarget $asset.target
        $item = Get-Item $asset.source

        if ($item.PSIsContainer) {
            if (-not (Test-Path $target)) { New-Item -ItemType Directory -Path $target -Force | Out-Null }
            $files = Get-ChildItem -Path $asset.source -Recurse -File
            foreach ($file in $files) {
                $relPath = $file.FullName.Substring($asset.source.Length).TrimStart('\')
                $targetPath = Join-Path $target $relPath
                $targetDir = Split-Path $targetPath -Parent
                if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
                Copy-Item -Path $file.FullName -Destination $targetPath -Force
                $count++
            }
        } else {
            $targetDir = Split-Path $target -Parent
            if (-not (Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
            Copy-Item -Path $asset.source -Destination $target -Force
            $count++
        }
    }
    return $count
}

Write-Host "`n========================================"
Write-Host "Claude Configuration Backup"
Write-Host "========================================`n"

Write-Host "[Reading] Config: $SourcesJson"
$config = Get-Content $SourcesJson -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Host "[Success] Config loaded`n"

if (-not (Test-Path $BackupRoot)) {
    Write-Host "[Creating] Backup root: $BackupRoot"
    New-Item -ItemType Directory -Path $BackupRoot -Force | Out-Null
}

$totalFiles = 0

Write-Host "[Global Layer] Starting backup"
$gc = $config.layers.global.claudeDirBackup
Write-Host "  Source: $($gc.source)"
Write-Host "  Mode: $($gc.mode)"
$count = Backup-WithExclude -Source $gc.source -Target (Join-Path $BackupRoot $gc.target) -Exclude $gc.exclude
$totalFiles += $count
Write-Host "  [Done] $count files"

if ($config.layers.global.auxiliaryAssets) {
    Write-Host "  Backing up auxiliary assets..."
    $count = Backup-Assets -Assets $config.layers.global.auxiliaryAssets -BaseTarget $BackupRoot
    $totalFiles += $count
    Write-Host "  [Done] $count files"
}

Write-Host "`n[Domain Layer] Starting backup"
foreach ($domainName in $config.layers.domains.PSObject.Properties.Name) {
    Write-Host "  Domain: $domainName"
    $dc = $config.layers.domains.$domainName.claudeDirBackup
    Write-Host "    Source: $($dc.source)"
    $count = Backup-WithExclude -Source $dc.source -Target (Join-Path $BackupRoot $dc.target) -Exclude $dc.exclude
    $totalFiles += $count
    Write-Host "    [Done] $count files"

    if ($config.layers.domains.$domainName.auxiliaryAssets) {
        Write-Host "    Backing up auxiliary assets..."
        $count = Backup-Assets -Assets $config.layers.domains.$domainName.auxiliaryAssets -BaseTarget $BackupRoot
        $totalFiles += $count
        Write-Host "    [Done] $count files"
    }
}

Write-Host "`n========================================"
Write-Host "[Complete] Backup finished"
Write-Host "========================================"
Write-Host "[Stats] Total files: $totalFiles"
Write-Host "[Stats] Backup location: $BackupRoot"
Write-Host ""
