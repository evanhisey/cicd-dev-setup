[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'

function Test-CommandAvailable {
    param([string]$Name)
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Ensure-WingetPackage {
    param(
        [string]$PackageId,
        [string]$DisplayName
    )

    $installed = winget list --id $PackageId --exact 2>$null | Select-String $PackageId
    if (-not $installed) {
        Write-Host "Installing $DisplayName..."
        winget install --id $PackageId --source winget --accept-source-agreements --accept-package-agreements --silent
    }
    else {
        Write-Host "$DisplayName is installed. Updating..."
        winget upgrade --id $PackageId --source winget --accept-source-agreements --accept-package-agreements --silent
    }
}

function Ensure-VisualStudioCodeExtensions {
    param([string[]]$Extensions)

    if (-not (Test-CommandAvailable -Name 'code')) {
        Write-Host "Visual Studio Code CLI not found. Please install VS Code first."
        return
    }

    foreach ($extension in $Extensions) {
        & code --install-extension $extension --force
    }
}

Write-Host "Checking for required Windows tooling..."

# Git for Git Bash and Git tools
if (-not (Test-CommandAvailable -Name 'git')) {
    Write-Host "Installing Git..."
    Ensure-WingetPackage -PackageId 'Git.Git' -DisplayName 'Git'
}
else {
    Write-Host "Git is installed. Updating Git..."
    winget upgrade --id Git.Git --source winget --accept-source-agreements --accept-package-agreements --silent
}

# Terraform
if (-not (Test-CommandAvailable -Name 'terraform')) {
    Write-Host "Installing Terraform..."
    Ensure-WingetPackage -PackageId 'Hashicorp.Terraform' -DisplayName 'Terraform'
}
else {
    Write-Host "Terraform is installed. Updating Terraform..."
    winget upgrade --id Hashicorp.Terraform --source winget --accept-source-agreements --accept-package-agreements --silent
}

# AWS CLI
if (-not (Test-CommandAvailable -Name 'aws')) {
    Write-Host "Installing AWS CLI..."
    Ensure-WingetPackage -PackageId 'Amazon.AWSCLI' -DisplayName 'AWS CLI'
}
else {
    Write-Host "AWS CLI is installed. Updating AWS CLI..."
    winget upgrade --id Amazon.AWSCLI --source winget --accept-source-agreements --accept-package-agreements --silent
}

# Visual Studio Code via winget
Ensure-WingetPackage -PackageId 'Microsoft.VisualStudioCode' -DisplayName 'Visual Studio Code'

# Configure VS Code for PowerShell, Ansible, Terraform, and Notepad comments
if (Test-CommandAvailable -Name 'code') {
    $settingsPath = Join-Path $HOME '.vscode\settings.json'
    $settingsDir = Split-Path $settingsPath -Parent
    if (-not (Test-Path $settingsDir)) {
        New-Item -ItemType Directory -Path $settingsDir -Force | Out-Null
    }

    $settings = @{}
    if (Test-Path $settingsPath) {
        $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json -AsHashtable -Depth 20
    }

    $settings['files.trimTrailingWhitespace'] = $true
    $settings['editor.insertSpaces'] = $true
    $settings['editor.tabSize'] = 2
    $settings['editor.wordWrap'] = 'on'
    $settings['terminal.integrated.defaultProfile.windows'] = 'Git Bash'
    $settings['git.openDiffOnClick'] = $false
    $settings['git.enableSmartCommit'] = $true
    $settings['comments.insertSpace'] = $true
    $settings['comments.ignoreEmptyLines'] = $false

    $settings | ConvertTo-Json -Depth 20 | Set-Content -Path $settingsPath -Encoding utf8

    Ensure-VisualStudioCodeExtensions -Extensions @(
        'ms-vscode.powershell',
        'redhat.ansible',
        'hashicorp.terraform'
    )
}

# Configure Git to use Notepad for comments and commit messages
if (Test-CommandAvailable -Name 'git') {
    git config --global core.editor "notepad"
    git config --global core.pager "cat"
    git config --global core.autocrlf false
    git config --global init.defaultBranch main
    git config --global gui.editor "notepad"
}

Write-Host ""
Write-Host "Installation completed."
Write-Host "To connect GitHub Copilot Enterprise, open VS Code, click the Accounts icon in the lower-left corner, choose Sign in with GitHub Enterprise, and if needed add the following to your settings.json:"
Write-Host '"github.copilot.advanced": { "authProvider": "github-enterprise" }'
