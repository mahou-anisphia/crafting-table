#Requires -Version 5.1
<#
.SYNOPSIS
    Batch upload a local directory to an S3 bucket using the AWS CLI default profile.

.DESCRIPTION
    Uses `aws s3 sync` to upload all files from a local directory to a
    configurable S3 bucket and key prefix. AWS credentials are sourced from
    the AWS CLI default (or named) profile — no credentials are stored in
    this script.

.EXAMPLE
    .\batch-upload.ps1
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
if (-not $S3_BUCKET) {
    Write-Error "`$S3_BUCKET must be set in config.ps1"
    exit 1
}

if (-not $LOCAL_DIR) {
    Write-Error "`$LOCAL_DIR must be set in config.ps1"
    exit 1
}

if (-not (Test-Path $LOCAL_DIR)) {
    Write-Error "Local directory not found: $LOCAL_DIR"
    exit 1
}

# ---------------------------------------------------------------------------
# Check aws CLI is available
# ---------------------------------------------------------------------------
if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
    Write-Error "AWS CLI not found. Install it from https://aws.amazon.com/cli/ and ensure it is on your PATH."
    exit 1
}

# ---------------------------------------------------------------------------
# Build S3 destination URI
# ---------------------------------------------------------------------------
$S3Prefix  = if ($S3_PREFIX) { $S3_PREFIX.TrimStart("/") } else { "" }
$S3Target  = "s3://$S3_BUCKET/$S3Prefix".TrimEnd("/") + "/"

$Profile   = if ($AWS_PROFILE) { $AWS_PROFILE } else { "default" }
$DryRun    = if ($DRY_RUN)     { $true }         else { $false }

# ---------------------------------------------------------------------------
# Build command arguments
# ---------------------------------------------------------------------------
$AwsArgs = @(
    "s3", "sync",
    $LOCAL_DIR,
    $S3Target,
    "--profile", $Profile
)

if ($DryRun) {
    $AwsArgs += "--dryrun"
    Write-Host "DRY RUN enabled — no files will actually be uploaded." -ForegroundColor Yellow
}

if ($EXTRA_FLAGS) {
    # Split extra flags string into individual tokens
    $AwsArgs += $EXTRA_FLAGS -split '\s+'
}

# ---------------------------------------------------------------------------
# Show summary before running
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "Uploading to S3"
Write-Host "  Source  : $LOCAL_DIR"
Write-Host "  Target  : $S3Target"
Write-Host "  Profile : $Profile"
if ($DryRun) { Write-Host "  Mode    : DRY RUN" -ForegroundColor Yellow }
Write-Host ""

# ---------------------------------------------------------------------------
# Run
# ---------------------------------------------------------------------------
& aws @AwsArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "AWS CLI exited with code $LASTEXITCODE"
    exit $LASTEXITCODE
}

Write-Host ""
if ($DryRun) {
    Write-Host "Dry run complete. Review output above, then set `$DRY_RUN = `$false in config.ps1 to upload for real." -ForegroundColor Yellow
} else {
    Write-Host "Upload complete." -ForegroundColor Green
}
