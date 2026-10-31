# Portable Unix toolkit for Windows PowerShell
# No administrator privileges or permanent system changes.
# Usage: irm https://raw.githubusercontent.com/USER/REPO/main/setup.ps1 | iex

$ErrorActionPreference = "Stop"

$toolDir = Join-Path $HOME "unix-tools"
New-Item -ItemType Directory -Force -Path $toolDir | Out-Null

# Pinned versions for reproducibility.
$tools = @(
    @{
        Name = "busybox"
        Url  = "https://frippery.org/files/busybox/busybox.exe"
        Type = "exe"
    },
    @{
        Name = "rg"
        Url  = "https://github.com/BurntSushi/ripgrep/releases/download/14.1.1/ripgrep-14.1.1-x86_64-pc-windows-msvc.zip"
        Type = "zip"
    },
    @{
        Name = "fd"
        Url  = "https://github.com/sharkdp/fd/releases/download/v10.2.0/fd-v10.2.0-x86_64-pc-windows-msvc.zip"
        Type = "zip"
    },
    @{
        Name = "jq"
        Url  = "https://github.com/jqlang/jq/releases/download/jq-1.8.1/jq-windows-amd64.exe"
        Type = "exe"
    },
    @{
        Name = "yq"
        Url  = "https://github.com/mikefarah/yq/releases/download/v4.47.1/yq_windows_amd64.exe"
        Type = "exe"
    },
    @{
        Name = "bat"
        Url  = "https://github.com/sharkdp/bat/releases/download/v0.25.0/bat-v0.25.0-x86_64-pc-windows-msvc.zip"
        Type = "zip"
    },
    @{
        Name = "fzf"
        Url  = "https://github.com/junegunn/fzf/releases/download/v0.65.2/fzf-0.65.2-windows_amd64.zip"
        Type = "zip"
    },
    @{
        Name = "zoxide"
        Url  = "https://github.com/ajeetdsouza/zoxide/releases/download/v0.9.8/zoxide-0.9.8-x86_64-pc-windows-msvc.zip"
        Type = "zip"
    },
    @{
        Name = "uv"
        Url  = "https://github.com/astral-sh/uv/releases/download/0.9.5/uv-x86_64-pc-windows-msvc.zip"
        Type = "zip"
    }
)

foreach ($tool in $tools) {
    $name = $tool.Name
    $target = Join-Path $toolDir "$name.exe"

    if (Test-Path $target) {
        Write-Host "[skip] $name"
        continue
    }

    Write-Host "[download] $name"

    try {
        if ($tool.Type -eq "exe") {
            Invoke-WebRequest -Uri $tool.Url -OutFile $target
        }
        else {
            $tempDir = Join-Path $env:TEMP "unix-tools-$name"
            $zipFile = "$tempDir.zip"

            if (Test-Path $tempDir) {
                Remove-Item $tempDir -Recurse -Force
            }

            Invoke-WebRequest -Uri $tool.Url -OutFile $zipFile
            Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force

            $binary = Get-ChildItem -Path $tempDir -Filter "$name.exe" -Recurse -File |
                Select-Object -First 1

            if (-not $binary) {
                throw "$name.exe not found in archive"
            }

            Copy-Item $binary.FullName -Destination $target -Force

            Remove-Item $tempDir -Recurse -Force
            Remove-Item $zipFile -Force
        }

        Write-Host "[ok] $name"
    }
    catch {
        Write-Warning "Failed to install ${name}: $_"
        if (Test-Path $target) {
            Remove-Item $target -Force
        }
    }
}

# Add tools to the current PowerShell process.
if (($env:PATH -split ';') -notcontains $toolDir) {
    $env:PATH = "$toolDir;$env:PATH"
}

# BusyBox supplies grep, sed, awk, find, xargs, etc.
# PowerShell functions make these commands directly accessible.
$busyboxCommands = @(
    "grep", "sed", "awk", "find", "xargs",
    "sort", "uniq", "cut", "tr", "wc",
    "head", "tail", "tee", "touch",
    "diff", "patch", "gzip", "gunzip",
    "tar", "wget"
)

if (Test-Path (Join-Path $toolDir "busybox.exe")) {
    foreach ($cmd in $busyboxCommands) {
        $functionBody = "busybox.exe $cmd @args"
        Set-Item -Path "Function:\global:$cmd" -Value ([scriptblock]::Create($functionBody))
    }
}

Write-Host ""
Write-Host "Unix tools ready: $toolDir"
Write-Host "Try: rg --version; jq --version; grep --help"
