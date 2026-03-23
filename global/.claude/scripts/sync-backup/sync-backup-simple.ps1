param(
    [Parameter(Mandatory=$true)]
    [string]$BackupRoot,

    [Parameter(Mandatory=$false)]
    [string]$SourcesJson = "C:\Users\admin\.claude\scripts\sync-backup\sources.json"
)

$ErrorActionPreference = "Stop"

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
$globalSource = $config.layers.global.claudeDirBackup.source
$globalTarget = Join-Path $BackupRoot $config.layers.global.claudeDirBackup.target

if (Test-Path $globalSource) {
    Write-Host "  Copying: $globalSource"
    Copy-Item -Path "$globalSource\*" -Destination $globalTarget -Recurse -Force -ErrorAction SilentlyContinue
    $files = Get-ChildItem -Path $globalTarget -Recurse -File -ErrorAction SilentlyContinue
    $totalFiles += $files.Count
    Write-Host "  [Done] $($files.Count) files"
} else {
    Write-Host "  [Warning] Source not found"
}

Write-Host "`n[Domain Layer] Starting backup"
foreach ($domainName in $config.layers.domains.PSObject.Properties.Name) {
    Write-Host "  Domain: $domainName"
    $domainConfig = $config.layers.domains.$domainName
    $domainSource = $domainConfig.claudeDirBackup.source
    $domainTarget = Join-Path $BackupRoot $domainConfig.claudeDirBackup.target

    if (Test-Path $domainSource) {
        Write-Host "    Copying: $domainSource"
        Copy-Item -Path "$domainSource\*" -Destination $domainTarget -Recurse -Force -ErrorAction SilentlyContinue
        $files = Get-ChildItem -Path $domainTarget -Recurse -File -ErrorAction SilentlyContinue
        $totalFiles += $files.Count
        Write-Host "    [Done] $($files.Count) files"
    } else {
        Write-Host "    [Warning] Source not found"
    }
}

Write-Host "`n========================================"
Write-Host "[Complete] Backup finished"
Write-Host "========================================"
Write-Host "[Stats] Total files: $totalFiles"
Write-Host "[Stats] Backup location: $BackupRoot"
Write-Host ""
