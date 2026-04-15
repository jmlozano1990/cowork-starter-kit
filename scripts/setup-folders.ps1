# setup-folders.ps1 — Create Cowork Project folder structure for a preset (Windows)
# Usage: .\scripts\setup-folders.ps1 [preset-name]
# If preset-name is not provided, the script will prompt you.

param(
    [string]$Preset = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Supported presets and their subfolder lists ---
$PresetFolders = @{
    "study"              = @("Papers", "Notes", "Flashcards", "Assignments", "Resources")
    "research"           = @("Literature", "Notes", "Drafts", "Data", "References")
    "writing"            = @("Drafts", "Published", "Ideas", "Research", "Voice-and-Style")
    "project-management" = @("Active-Projects", "Archive", "Templates", "Meeting-Notes", "Inbox")
    "creative"           = @("Projects", "Inspiration", "Drafts", "Assets", "Archive")
    "business-admin"     = @("Inbox", "Reports", "Emails", "Meetings", "Templates")
}

$ValidPresets = ($PresetFolders.Keys | Sort-Object) -join ", "

# --- Get preset name ---
if ([string]::IsNullOrWhiteSpace($Preset)) {
    Write-Host "Which preset would you like to set up?"
    Write-Host "Options: $ValidPresets"
    $Preset = Read-Host "Preset name"
}

$Preset = $Preset.ToLower().Replace(" ", "-")

# --- Validate preset name ---
if (-not $PresetFolders.ContainsKey($Preset)) {
    Write-Error "Error: '$Preset' is not a recognized preset. Valid presets: $ValidPresets"
    exit 1
}

# --- Build target path ---
$HomeDir = [System.Environment]::GetFolderPath("UserProfile")
$DefaultBase = Join-Path $HomeDir "Documents\Claude\Projects"
$Target = Join-Path $DefaultBase $Preset

# Normalize path to resolve any . or .. components
$ResolvedTarget = [System.IO.Path]::GetFullPath($Target)

# --- Path validation (S3 carry-forward) ---

# Reject path traversal — resolved path must start with home directory
if (-not $ResolvedTarget.StartsWith($HomeDir)) {
    Write-Error "Error: Target path must be inside your home directory ($HomeDir). Aborting."
    exit 1
}

# Reject home directory root itself
if ($ResolvedTarget -eq $HomeDir) {
    Write-Error "Error: Target path cannot be your home directory root. Aborting."
    exit 1
}

# Reject system directories
$SystemDirs = @(
    "C:\Windows",
    "C:\Program Files",
    "C:\Program Files (x86)",
    "C:\System Volume Information"
)

foreach ($sysDir in $SystemDirs) {
    if ($ResolvedTarget -eq $sysDir -or $ResolvedTarget.StartsWith("$sysDir\")) {
        Write-Error "Error: Cannot create folders inside system directory: $sysDir"
        exit 1
    }
}

# --- Confirm with user ---
Write-Host ""
Write-Host "Creating folder structure for preset: $Preset"
Write-Host "Target location: $ResolvedTarget"
Write-Host ""
$Confirm = Read-Host "Proceed? [y/N]"

if ($Confirm.ToLower() -ne "y" -and $Confirm.ToLower() -ne "yes") {
    Write-Host "Cancelled."
    exit 0
}

# --- Create folders ---
Write-Host ""
Write-Host "Creating folders..."

New-Item -ItemType Directory -Force -Path $ResolvedTarget | Out-Null
Write-Host "  Created: $ResolvedTarget"

foreach ($folder in $PresetFolders[$Preset]) {
    $FullPath = Join-Path $ResolvedTarget $folder
    New-Item -ItemType Directory -Force -Path $FullPath | Out-Null
    Write-Host "  Created: $FullPath"
}

Write-Host ""
Write-Host "Done. Your $Preset folder structure is ready at:"
Write-Host "  $ResolvedTarget"
Write-Host ""
Write-Host "Next step: In Cowork, assign this folder to your Project in Project Settings."
