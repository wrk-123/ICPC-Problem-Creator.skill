#!/usr/bin/env pwsh

<#
.SYNOPSIS
创建一个 ICPC 题目工作区脚手架。

.PARAMETER Name
工作区名称。默认会在 examples/<Name> 下创建。

.PARAMETER Interactive
是否创建交互题脚手架。

.EXAMPLE
./scripts/create-workspace.ps1 -Name "add-and-sum"

.EXAMPLE
./scripts/create-workspace.ps1 -Name "magic-and-crab" -Interactive
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name,

    [switch]$Interactive
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$exampleMarkerToken = "CODEX_EXAMPLE_MARKER:"

function Get-TemplateContent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$TemplatePath
    )

    return [System.IO.File]::ReadAllText($TemplatePath, [System.Text.Encoding]::UTF8)
}

function Write-Utf8File {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $directory = Split-Path -Parent $Path
    if (-not [string]::IsNullOrWhiteSpace($directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($Path, $Content, [System.Text.UTF8Encoding]::new($false))
}

if ($Name.IndexOfAny([char[]]@('/', '\')) -ge 0) {
    throw "Name 不能包含路径分隔符。"
}

if ($Name -notmatch '^[A-Za-z0-9][A-Za-z0-9._-]*$') {
    throw "Name 仅支持字母、数字、点、下划线和短横线，且必须以字母或数字开头。"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$workspacePath = Join-Path $repoRoot (Join-Path "examples" $Name)

if (Test-Path -LiteralPath $workspacePath) {
    throw "目标工作区已存在：$workspacePath"
}

$templateMap = @{
    Testlib           = Join-Path $PSScriptRoot "testlib.h"
    Checker           = Join-Path $PSScriptRoot "checker-template.cpp"
    InteractiveChecker = Join-Path $PSScriptRoot "interactive-checker-template.cpp"
    Validator         = Join-Path $PSScriptRoot "validator-template.cpp"
    InteractiveValidator = Join-Path $PSScriptRoot "interactive-validator-template.cpp"
    Generator         = Join-Path $PSScriptRoot "generator-template.cpp"
    Statement         = Join-Path $PSScriptRoot "statement-template.md"
    InteractiveStatement = Join-Path $PSScriptRoot "interactive-statement-template.md"
    SolutionDoc       = Join-Path $PSScriptRoot "solution-template.md"
    Solution          = Join-Path $PSScriptRoot "solution-template.cpp"
    BruteForce        = Join-Path $PSScriptRoot "brute-force-template.cpp"
    WrongSol          = Join-Path $PSScriptRoot "wrong-sol-template.cpp"
    InteractiveSolution = Join-Path $PSScriptRoot "interactive-solution-template.cpp"
    InteractiveBruteForce = Join-Path $PSScriptRoot "interactive-brute-force-template.cpp"
    InteractiveWrongSol = Join-Path $PSScriptRoot "interactive-wrong-sol-template.cpp"
}

foreach ($entry in $templateMap.GetEnumerator()) {
    if (-not (Test-Path -LiteralPath $entry.Value)) {
        throw "缺少模板文件：$($entry.Value)"
    }
}

$directories = @(
    $workspacePath,
    (Join-Path $workspacePath "include"),
    (Join-Path $workspacePath "docs"),
    (Join-Path $workspacePath "src"),
    (Join-Path $workspacePath "testdata")
)

foreach ($directory in $directories) {
    New-Item -ItemType Directory -Path $directory -Force | Out-Null
}

$problemTitle = ($Name -split '[-_.]') | Where-Object { $_ } | ForEach-Object {
    if ($_.Length -eq 1) {
        $_.ToUpperInvariant()
    } else {
        $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1)
    }
}
$problemTitle = ($problemTitle -join ' ')

$replacements = @{
    "{{PROBLEM_NAME}}"  = $Name
    "{{PROBLEM_TITLE}}" = $problemTitle
}

function Expand-Template {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $expanded = $Content.Replace("名称", $Name)
    foreach ($pair in $replacements.GetEnumerator()) {
        $expanded = $expanded.Replace($pair.Key, $pair.Value)
    }
    return $expanded
}

function Strip-ExampleMarker {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Content
    )

    $lines = $Content -split "`r?`n"
    $filtered = foreach ($line in $lines) {
        if ($line -notmatch [regex]::Escape($exampleMarkerToken)) {
            $line
        }
    }
    return ($filtered -join "`n").TrimEnd() + "`n"
}

Copy-Item -LiteralPath $templateMap.Testlib -Destination (Join-Path $workspacePath "include/testlib.h")

$statementTemplate = if ($Interactive) { $templateMap.InteractiveStatement } else { $templateMap.Statement }
$checkerTemplate = if ($Interactive) { $templateMap.InteractiveChecker } else { $templateMap.Checker }
$validatorTemplate = if ($Interactive) { $templateMap.InteractiveValidator } else { $templateMap.Validator }
$solutionTemplate = if ($Interactive) { $templateMap.InteractiveSolution } else { $templateMap.Solution }
$bruteForceTemplate = if ($Interactive) { $templateMap.InteractiveBruteForce } else { $templateMap.BruteForce }
$wrongSolTemplate = if ($Interactive) { $templateMap.InteractiveWrongSol } else { $templateMap.WrongSol }

Write-Utf8File -Path (Join-Path $workspacePath "docs/statement.md") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $statementTemplate)))
Write-Utf8File -Path (Join-Path $workspacePath "docs/solution.md") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $templateMap.SolutionDoc)))
Write-Utf8File -Path (Join-Path $workspacePath "src/checker.cpp") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $checkerTemplate)))
Write-Utf8File -Path (Join-Path $workspacePath "src/validator.cpp") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $validatorTemplate)))
Write-Utf8File -Path (Join-Path $workspacePath "src/generator.cpp") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $templateMap.Generator)))
Write-Utf8File -Path (Join-Path $workspacePath "src/solution.cpp") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $solutionTemplate)))
Write-Utf8File -Path (Join-Path $workspacePath "src/brute-force.cpp") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $bruteForceTemplate)))
Write-Utf8File -Path (Join-Path $workspacePath "src/wrong-sol.cpp") -Content (Strip-ExampleMarker (Expand-Template (Get-TemplateContent $wrongSolTemplate)))

if ($Interactive) {
    Write-Utf8File -Path (Join-Path $workspacePath "testdata/1.in") -Content "42`n"
} else {
    Write-Utf8File -Path (Join-Path $workspacePath "testdata/1.in") -Content "5`n"
    Write-Utf8File -Path (Join-Path $workspacePath "testdata/1.out") -Content "5`n"
}

Write-Host "Workspace created at $workspacePath"
