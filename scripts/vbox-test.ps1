<#
.SYNOPSIS
    Create or boot an AngelOS 11 test VM in Oracle VirtualBox on Windows.
.EXAMPLE
    .\scripts\vbox-test.ps1 -IsoPath "C:\Users\Michael\Desktop\archlinux-2026.11.01-x86_64.iso"
    .\scripts\vbox-test.ps1 -IsoPath ".\out\angelos-11-v0.1.0-x86_64.iso" -DryRun
#>
[CmdletBinding()]
param(
    [string]$VmName = "AngelOS-11-Test",

    [Parameter(Mandatory = $true)]
    [string]$IsoPath,

    [int]$MemoryMB = 8192,
    [int]$Cpus = 4,
    [int]$DiskSizeMB = 49152,
    [int]$VramMB = 128,
    [switch]$Disable3D,
    [switch]$Start,
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

function Resolve-VBoxManage {
    $cmd = Get-Command VBoxManage.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    $defaultPath = Join-Path $Env:ProgramFiles "Oracle\VirtualBox\VBoxManage.exe"
    if (Test-Path $defaultPath) { return $defaultPath }

    throw "VBoxManage.exe was not found in PATH or '$defaultPath'. Install Oracle VirtualBox first."
}

$ResolvedIso = (Resolve-Path $IsoPath).Path
$VBoxManage = if ($DryRun) { "VBoxManage.exe" } else { Resolve-VBoxManage }
$VmBaseDir = Join-Path $Env:USERPROFILE "VirtualBox VMs\$VmName"
$VdiPath = Join-Path $VmBaseDir "$VmName.vdi"

function Invoke-VBox {
    param([string[]]$ArgsList)
    if ($DryRun) {
        Write-Host "[DryRun] $VBoxManage $($ArgsList -join ' ')"
    } else {
        & $VBoxManage @ArgsList
        if ($LASTEXITCODE -ne 0) {
            throw "VBoxManage failed with exit code $LASTEXITCODE"
        }
    }
}

$Exists = $false
if (-not $DryRun) {
    $vmList = & $VBoxManage list vms
    if ($vmList -match "`"$([regex]::Escape($VmName))`"") {
        $Exists = $true
    }
}

if (-not $Exists) {
    Write-Host "==> Creating VirtualBox VM '$VmName'..."
    Invoke-VBox @("createvm", "--name", $VmName, "--ostype", "ArchLinux_64", "--register")
    Invoke-VBox @("modifyvm", $VmName,
        "--memory", "$MemoryMB",
        "--cpus", "$Cpus",
        "--firmware", "efi",
        "--graphicscontroller", "vmsvga",
        "--vram", "$VramMB",
        "--accelerate3d", $(if ($Disable3D) { "off" } else { "on" }),
        "--nic1", "nat",
        "--audio-driver", "was",
        "--audio-out", "on",
        "--clipboard-mode", "bidirectional",
        "--draganddrop", "bidirectional",
        "--boot1", "dvd",
        "--boot2", "disk",
        "--boot3", "none",
        "--boot4", "none"
    )

    Invoke-VBox @("createmedium", "disk", "--filename", $VdiPath, "--size", "$DiskSizeMB", "--format", "VDI")
    Invoke-VBox @("storagectl", $VmName, "--name", "SATA Controller", "--add", "sata", "--controller", "IntelAhci")
    Invoke-VBox @("storageattach", $VmName, "--storagectl", "SATA Controller", "--port", "0", "--device", "0", "--type", "hdd", "--medium", $VdiPath)
    Invoke-VBox @("storagectl", $VmName, "--name", "IDE Controller", "--add", "ide")
}

Write-Host "==> Attaching ISO '$ResolvedIso' to '$VmName'..."
Invoke-VBox @("storageattach", $VmName, "--storagectl", "IDE Controller", "--port", "0", "--device", "0", "--type", "dvddrive", "--medium", $ResolvedIso)

if ($Start) {
    Write-Host "==> Starting '$VmName'..."
    Invoke-VBox @("startvm", $VmName, "--type", "gui")
} else {
    Write-Host "==> VM '$VmName' is configured. Run with -Start or launch from VirtualBox Manager."
}
