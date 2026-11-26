<#
.SYNOPSIS
    Bump the SemVer version in VERSION and scaffold a CHANGELOG.md entry.
.EXAMPLE
    .\scripts\bump-version.ps1 -Part minor
    .\scripts\bump-version.ps1 -Version 0.1.0 -Tag
#>
[CmdletBinding()]
param(
    [ValidateSet("patch", "minor", "major")]
    [string]$Part = "patch",

    [string]$Version,

    [switch]$Tag
)

$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $PSScriptRoot
$VersionFile = Join-Path $RepoRoot "VERSION"
$ChangelogFile = Join-Path $RepoRoot "CHANGELOG.md"

$Current = (Get-Content -Raw $VersionFile).Trim()
if ($Current -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
    throw "Current VERSION '$Current' is not a plain MAJOR.MINOR.PATCH string."
}

if ($Version) {
    if ($Version -notmatch '^\d+\.\d+\.\d+(-[0-9A-Za-z.-]+)?$') {
        throw "Provided -Version '$Version' is not valid SemVer."
    }
    $Next = $Version
} else {
    $Major = [int]$Matches[1]
    $Minor = [int]$Matches[2]
    $Patch = [int]$Matches[3]

    switch ($Part) {
        "major" { $Major++; $Minor = 0; $Patch = 0 }
        "minor" { $Minor++; $Patch = 0 }
        "patch" { $Patch++ }
    }
    $Next = "$Major.$Minor.$Patch"
}

Set-Content -Path $VersionFile -Value "$Next`n" -NoNewline -Encoding utf8NoBOM
Write-Host "Updated VERSION: $Current -> $Next"

if (Test-Path $ChangelogFile) {
    $Today = Get-Date -Format "yyyy-MM-dd"
    $Content = Get-Content -Raw $ChangelogFile
    if ($Content -notmatch "## \[$Next\]") {
        $Replacement = "## [Unreleased]`r`n`r`n## [$Next] - $Today`r`n### Added`r`n- Release $Next"
        $Updated = $Content -replace "## \[Unreleased\]", $Replacement
        Set-Content -Path $ChangelogFile -Value $Updated -NoNewline -Encoding utf8NoBOM
        Write-Host "Added [$Next] section to CHANGELOG.md"
    }
}

if ($Tag) {
    Push-Location $RepoRoot
    try {
        git add VERSION CHANGELOG.md
        git commit -m "chore(release): bump version to v$Next"
        git tag -a "v$Next" -m "AngelOS 11 v$Next"
        Write-Host "Created commit and tag v$Next (push with: git push origin main --tags)"
    } finally {
        Pop-Location
    }
}
