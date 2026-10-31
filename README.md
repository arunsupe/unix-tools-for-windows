Portable Unix Tools for Windows

A lightweight PowerShell bootstrap script that downloads and configures common Unix command-line utilities on Windows.

No installers, administrator privileges, WSL, or Bash required.

Quick Start

Run in PowerShell:

irm https://raw.githubusercontent.com/USER/REPO/main/setup.ps1 | iex

Replace USER/REPO with your GitHub username and repository.

Included Tools

Tool	Description
BusyBox	Unix utilities including grep, sed, awk, find, tar, and more
ripgrep (rg)	Fast text searching
fd	Fast file searching
jq	JSON processing
yq	YAML processing
bat	Enhanced file viewer
fzf	Fuzzy finder
zoxide	Smart directory navigation
uv	Python package and environment manager

How It Works

1. Downloads portable Windows binaries into ~/unix-tools.
2. Skips tools already downloaded.
3. Adds the directory to the current PowerShell session’s PATH.
4. Exposes common BusyBox utilities as PowerShell commands.

The shell remains PowerShell, with Unix utilities available directly.

Examples

rg "error" .
Get-Content logfile.txt | grep "ERROR" | wc -l
jq '.name' data.json
rg "TODO" . | grep "urgent" | head -20

Notes

* Designed for 64-bit Windows.
* No permanent system modifications.
* Tools remain available on disk after the session ends.
* Run the bootstrap script again in a new PowerShell session to reactivate the tools.
* Bash-specific syntax and shell scripts are not supported.
* Downloads require internet access.

License

The bootstrap script is provided as-is. Downloaded utilities retain their respective open-source licenses.
