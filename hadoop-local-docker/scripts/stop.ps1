$ErrorActionPreference = "Stop"
Set-Location (Split-Path -Parent $PSScriptRoot)
. (Join-Path $PSScriptRoot "lib.ps1")

Require-Docker
$compose = Resolve-ComposeCommand

& $compose[0] @($compose[1..($compose.Length - 1)] + @("down"))
Write-Host "Hadoop cluster stopped."
