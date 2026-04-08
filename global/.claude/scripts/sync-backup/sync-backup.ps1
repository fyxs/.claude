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

    # Sync deletions: remove files in target that no longer exist in source
    $targetItems = Get-ChildItem -Path $Target -Recurse -Force
    foreach ($targetItem in $targetItems) {
        $relPath = $targetItem.FullName.Substring($Target.Length).TrimStart('\')
        $sourcePath = Join-Path $Source $relPath
        if (-not (Test-Path $sourcePath)) {
            if ($targetItem.PSIsContainer) {
                Remove-Item -Path $targetItem.FullName -Recurse -Force -ErrorAction SilentlyContinue
            } else {
                Remove-Item -Path $targetItem.FullName -Force -ErrorAction SilentlyContinue
            }
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
            Copy-Item -Path $item.FullName -Destination $target -Force
            $count++
        }
    }

    # Sync deletions: remove files in target that no longer exist in source
    foreach ($asset in $Assets) {
        $target = Join-Path $BaseTarget $asset.target
        if (Test-Path $target) {
            if ((Get-Item $asset.source -ErrorAction SilentlyContinue).PSIsContainer) {
                $targetItems = Get-ChildItem -Path $target -Recurse -Force
                foreach ($targetItem in $targetItems) {
                    $relPath = $targetItem.FullName.Substring($target.Length).TrimStart('\')
                    $sourcePath = Join-Path $asset.source $relPath
                    if (-not (Test-Path $sourcePath)) {
                        if ($targetItem.PSIsContainer) {
                            Remove-Item -Path $targetItem.FullName -Recurse -Force -ErrorAction SilentlyContinue
                        } else {
                            Remove-Item -Path $targetItem.FullName -Force -ErrorAction SilentlyContinue
                        }
                    }
                }
            } else {
                if (-not (Test-Path $asset.source)) {
                    Remove-Item -Path $target -Force -ErrorAction SilentlyContinue
                }
            }
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

if ($config.layers.applications) {
    Write-Host "`n[Application Layer] Starting backup"
    foreach ($appName in $config.layers.applications.PSObject.Properties.Name) {
        Write-Host "  Application: $appName"
        $ac = $config.layers.applications.$appName.claudeDirBackup
        Write-Host "    Source: $($ac.source)"
        $count = Backup-WithExclude -Source $ac.source -Target (Join-Path $BackupRoot $ac.target) -Exclude $ac.exclude
        $totalFiles += $count
        Write-Host "    [Done] $count files"

        if ($config.layers.applications.$appName.auxiliaryAssets) {
            Write-Host "    Backing up auxiliary assets..."
            $count = Backup-Assets -Assets $config.layers.applications.$appName.auxiliaryAssets -BaseTarget $BackupRoot
            $totalFiles += $count
            Write-Host "    [Done] $count files"
        }
    }
}

if ($config.layers.projects) {
    Write-Host "`n[Project Layer] Starting backup"
    foreach ($projectName in $config.layers.projects.PSObject.Properties.Name) {
        Write-Host "  Project: $projectName"
        $pc = $config.layers.projects.$projectName.claudeDirBackup
        Write-Host "    Source: $($pc.source)"
        $count = Backup-WithExclude -Source $pc.source -Target (Join-Path $BackupRoot $pc.target) -Exclude $pc.exclude
        $totalFiles += $count
        Write-Host "    [Done] $count files"

        if ($config.layers.projects.$projectName.auxiliaryAssets) {
            Write-Host "    Backing up auxiliary assets..."
            $count = Backup-Assets -Assets $config.layers.projects.$projectName.auxiliaryAssets -BaseTarget $BackupRoot
            $totalFiles += $count
            Write-Host "    [Done] $count files"
        }
    }
}

Write-Host "`n[Cleanup] Removing nested .git directories..."
$rootGitPath = Join-Path $BackupRoot ".git"
$gitDirs = Get-ChildItem -Path $BackupRoot -Directory -Recurse -Force -Filter ".git" -ErrorAction SilentlyContinue | Where-Object { $_.FullName -ne $rootGitPath }
$gitCount = 0
foreach ($gitDir in $gitDirs) {
    Remove-Item -Path $gitDir.FullName -Recurse -Force -ErrorAction SilentlyContinue
    $gitCount++
}
if ($gitCount -gt 0) {
    Write-Host "  [Done] Removed $gitCount nested .git directories (excluding repository root)"
} else {
    Write-Host "  [Done] No nested .git directories found"
}

Write-Host "`n========================================"
Write-Host "[Complete] Backup finished"
Write-Host "========================================"
Write-Host "[Stats] Total files: $totalFiles"
Write-Host "[Stats] Backup location: $BackupRoot"
Write-Host ""
