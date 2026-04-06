#Requires -Version 5.1
<#
.SYNOPSIS
    Batch download files from URLs listed in a CSV column.

.DESCRIPTION
    Reads a CSV file, extracts URLs from a specified column, and downloads
    each file in parallel to an output directory.

.EXAMPLE
    .\batch-download.ps1
    Uses config.ps1 for all settings.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# Load config
# ---------------------------------------------------------------------------
$ConfigFile = Join-Path $PSScriptRoot "config.ps1"
if (-not (Test-Path $ConfigFile)) {
    Write-Error "config.ps1 not found. Copy config.sample.ps1 to config.ps1 and fill in your values."
    exit 1
}
. $ConfigFile

# ---------------------------------------------------------------------------
# Validate config
# ---------------------------------------------------------------------------
if (-not (Test-Path $CSV_FILE)) {
    Write-Error "CSV file not found: $CSV_FILE"
    exit 1
}

if (-not $URL_COLUMN) {
    Write-Error "`$URL_COLUMN must be set in config.ps1"
    exit 1
}

$ParallelJobs = if ($PARALLEL_JOBS) { [int]$PARALLEL_JOBS } else { 4 }

# ---------------------------------------------------------------------------
# Prepare output directory
# ---------------------------------------------------------------------------
$OutputDir = $OUTPUT_DIR
if (-not $OutputDir) { $OutputDir = Join-Path $PSScriptRoot "output" }

if (-not (Test-Path $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir | Out-Null
    Write-Host "Created output directory: $OutputDir"
}

# ---------------------------------------------------------------------------
# Read CSV
# ---------------------------------------------------------------------------
$Rows = Import-Csv -Path $CSV_FILE

if (-not ($Rows | Get-Member -Name $URL_COLUMN -ErrorAction SilentlyContinue)) {
    Write-Error "Column '$URL_COLUMN' not found in CSV. Available columns: $(($Rows[0].PSObject.Properties.Name) -join ', ')"
    exit 1
}

$Urls = $Rows | ForEach-Object { $_.$URL_COLUMN } | Where-Object { $_ -and $_.Trim() -ne "" }
$Total = $Urls.Count

if ($Total -eq 0) {
    Write-Warning "No URLs found in column '$URL_COLUMN'."
    exit 0
}

Write-Host "Found $Total URL(s) to download. Parallel jobs: $ParallelJobs"
Write-Host "Output directory: $OutputDir"
Write-Host ""

# ---------------------------------------------------------------------------
# Download (parallel via jobs)
# ---------------------------------------------------------------------------
$Results = [System.Collections.Concurrent.ConcurrentBag[PSCustomObject]]::new()
$Counter = [ref]0

$DownloadBlock = {
    param($Url, $OutputDir)
    try {
        $FileName = [System.IO.Path]::GetFileName(([uri]$Url).LocalPath)
        if (-not $FileName -or $FileName -eq "/") {
            $FileName = "file_" + [System.Guid]::NewGuid().ToString("N")
        }
        $Destination = Join-Path $OutputDir $FileName
        # Handle duplicate filenames
        $i = 1
        $BaseName = [System.IO.Path]::GetFileNameWithoutExtension($FileName)
        $Ext      = [System.IO.Path]::GetExtension($FileName)
        while (Test-Path $Destination) {
            $Destination = Join-Path $OutputDir "${BaseName}_${i}${Ext}"
            $i++
        }
        Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing
        [PSCustomObject]@{ Url = $Url; File = $Destination; Status = "OK"; Error = $null }
    } catch {
        [PSCustomObject]@{ Url = $Url; File = $null; Status = "FAIL"; Error = $_.Exception.Message }
    }
}

# Run in batches using PowerShell jobs
$AllJobs   = @()
$BatchUrls = $Urls

foreach ($Url in $BatchUrls) {
    while (@(Get-Job -State Running).Count -ge $ParallelJobs) {
        Start-Sleep -Milliseconds 200
    }
    $AllJobs += Start-Job -ScriptBlock $DownloadBlock -ArgumentList $Url, $OutputDir
}

Write-Host "Waiting for all downloads to complete..."
$AllJobs | Wait-Job | Out-Null

$Succeeded = 0
$Failed    = 0

foreach ($Job in $AllJobs) {
    $Result = Receive-Job -Job $Job
    Remove-Job -Job $Job

    if ($Result.Status -eq "OK") {
        $Succeeded++
        Write-Host "  [OK]   $($Result.File)" -ForegroundColor Green
    } else {
        $Failed++
        Write-Host "  [FAIL] $($Result.Url) — $($Result.Error)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Done. Succeeded: $Succeeded / $Total   Failed: $Failed"
if ($Failed -gt 0) { exit 1 }
