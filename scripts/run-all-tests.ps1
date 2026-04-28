#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [string[]]$Workspace,
    [switch]$SkipSmokeTest
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$examplesRoot = Join-Path $repoRoot "examples"
$artifactsRoot = Join-Path $repoRoot ".codex-test-artifacts"
$exampleMarkerToken = "CODEX_EXAMPLE_MARKER:"
New-Item -ItemType Directory -Path $artifactsRoot -Force | Out-Null
$tempRoot = Join-Path $artifactsRoot "tmp"
New-Item -ItemType Directory -Path $tempRoot -Force | Out-Null
$env:TEMP = $tempRoot
$env:TMP = $tempRoot

function Write-Log {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "[$timestamp] $Message"
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [string[]]$ArgumentList = @(),

        [string]$Description = $FilePath
    )

    $renderedArgs = if ($ArgumentList.Count -gt 0) {
        $ArgumentList -join " "
    } else {
        ""
    }

    Write-Log "START $Description"
    Write-Log "CMD   $FilePath $renderedArgs"
    & $FilePath @ArgumentList | Out-Host
    $exitCode = $LASTEXITCODE
    Write-Log "END   $Description (exit=$exitCode)"
    return $exitCode
}

function Assert-FileExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "缺少文件：$Path"
    }
}

function Assert-DirectoryExists {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Container)) {
        throw "缺少目录：$Path"
    }
}

function Assert-MarkerPresence {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [bool]$ShouldExist
    )

    $content = Get-Content -LiteralPath $Path -Raw
    $hasMarker = $content -match [regex]::Escape($exampleMarkerToken)
    if ($ShouldExist -and -not $hasMarker) {
        throw "模板缺少示例标识：$Path"
    }
    if (-not $ShouldExist -and $hasMarker) {
        throw "非模板文件不应包含示例标识：$Path"
    }
}

function Resolve-WorkspaceList {
    param(
        [string[]]$Requested
    )

    if ($Requested -and $Requested.Count -gt 0) {
        return $Requested | ForEach-Object {
            if ([System.IO.Path]::IsPathRooted($_)) {
                $_
            } else {
                Join-Path $repoRoot $_
            }
        }
    }

    return Get-ChildItem -LiteralPath $examplesRoot -Directory | Select-Object -ExpandProperty FullName
}

function Test-TemplateMarkers {
    $templateFiles = @(
        (Join-Path $PSScriptRoot "statement-template.md"),
        (Join-Path $PSScriptRoot "interactive-statement-template.md"),
        (Join-Path $PSScriptRoot "solution-template.md"),
        (Join-Path $PSScriptRoot "checker-template.cpp"),
        (Join-Path $PSScriptRoot "validator-template.cpp"),
        (Join-Path $PSScriptRoot "generator-template.cpp"),
        (Join-Path $PSScriptRoot "solution-template.cpp"),
        (Join-Path $PSScriptRoot "brute-force-template.cpp"),
        (Join-Path $PSScriptRoot "wrong-sol-template.cpp"),
        (Join-Path $PSScriptRoot "interactive-checker-template.cpp"),
        (Join-Path $PSScriptRoot "interactive-validator-template.cpp"),
        (Join-Path $PSScriptRoot "interactive-solution-template.cpp"),
        (Join-Path $PSScriptRoot "interactive-brute-force-template.cpp"),
        (Join-Path $PSScriptRoot "interactive-wrong-sol-template.cpp")
    )

    Write-Log "[template-markers]"
    foreach ($templateFile in $templateFiles) {
        Assert-FileExists $templateFile
        Assert-MarkerPresence -Path $templateFile -ShouldExist $true
    }
}

function Test-WorkspaceStructure {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath
    )

    Write-Log "[structure] $WorkspacePath"

    Assert-DirectoryExists $WorkspacePath
    Assert-DirectoryExists (Join-Path $WorkspacePath "include")
    Assert-DirectoryExists (Join-Path $WorkspacePath "docs")
    Assert-DirectoryExists (Join-Path $WorkspacePath "src")
    Assert-DirectoryExists (Join-Path $WorkspacePath "testdata")

    foreach ($relativePath in @(
        "include/testlib.h",
        "docs/statement.md",
        "docs/solution.md",
        "src/checker.cpp",
        "src/validator.cpp",
        "src/generator.cpp",
        "src/solution.cpp",
        "src/brute-force.cpp",
        "src/wrong-sol.cpp"
    )) {
        Assert-FileExists (Join-Path $WorkspacePath $relativePath)
    }

    $statement = Get-Content -LiteralPath (Join-Path $WorkspacePath "docs/statement.md") -Raw
    $solutionDoc = Get-Content -LiteralPath (Join-Path $WorkspacePath "docs/solution.md") -Raw

    if ($statement -notmatch '## 样例') {
        throw "题面缺少样例章节：$WorkspacePath"
    }
    if ($statement -notmatch '```input1') {
        throw "题面缺少 input1 样例块：$WorkspacePath"
    }
    if ([string]::IsNullOrWhiteSpace($solutionDoc)) {
        throw "题解为空：$WorkspacePath"
    }

    foreach ($relativePath in @(
        "docs/statement.md",
        "docs/solution.md",
        "src/checker.cpp",
        "src/validator.cpp",
        "src/generator.cpp",
        "src/solution.cpp",
        "src/brute-force.cpp",
        "src/wrong-sol.cpp"
    )) {
        Assert-MarkerPresence -Path (Join-Path $WorkspacePath $relativePath) -ShouldExist $false
    }
}

function Get-BinaryPath {
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputDir,

        [Parameter(Mandatory = $true)]
        [string]$BaseName
    )

    return Join-Path $OutputDir "$BaseName.exe"
}

function Invoke-DirectBuild {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath
    )

    $workspaceName = Split-Path -Leaf $WorkspacePath
    $runToken = "{0:yyyyMMdd-HHmmss}-{1}" -f (Get-Date), $PID
    $outputDir = Join-Path $artifactsRoot (Join-Path "build" "$workspaceName-$runToken")
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

    $includeDir = Join-Path $WorkspacePath "include"
    $compileTargets = @(
        @{ Source = "solution.cpp"; Name = "STD" },
        @{ Source = "brute-force.cpp"; Name = "BF" },
        @{ Source = "wrong-sol.cpp"; Name = "WA" },
        @{ Source = "checker.cpp"; Name = "CHECKER" },
        @{ Source = "validator.cpp"; Name = "VAL" },
        @{ Source = "generator.cpp"; Name = "GEN" }
    )

    foreach ($target in $compileTargets) {
        $sourcePath = Join-Path $WorkspacePath (Join-Path "src" $target.Source)
        $outputPath = Get-BinaryPath -OutputDir $outputDir -BaseName $target.Name
        $args = @(
            "-std=c++20",
            "-O2",
            "-Wall",
            "-Wextra",
            "-I", $includeDir,
            $sourcePath,
            "-o", $outputPath
        )
        if ((Invoke-LoggedCommand -FilePath "g++" -ArgumentList $args -Description "g++ build $($target.Name): $WorkspacePath") -ne 0) {
            throw "编译失败：$sourcePath"
        }
    }

    return $outputDir
}

function Invoke-ValidatorChecks {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath,

        [Parameter(Mandatory = $true)]
        [string]$BuildDir
    )

    $validator = Get-BinaryPath -OutputDir $BuildDir -BaseName "VAL"
    $generator = Get-BinaryPath -OutputDir $BuildDir -BaseName "GEN"
    $testdataFiles = Get-ChildItem -LiteralPath (Join-Path $WorkspacePath "testdata") -Filter "*.in" | Sort-Object Name

    foreach ($testcase in $testdataFiles) {
        Write-Log "START validator stdin: $($testcase.FullName)"
        Write-Log "CMD   Get-Content $($testcase.FullName) | & $validator"
        Get-Content -LiteralPath $testcase.FullName | & $validator | Out-Host
        $exitCode = $LASTEXITCODE
        Write-Log "END   validator stdin: $($testcase.FullName) (exit=$exitCode)"
        if ($exitCode -ne 0) {
            throw "validator 未通过：$($testcase.FullName)"
        }
    }

    Write-Log "[generator->validator] $WorkspacePath"
    $generated = & $generator 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "generator 执行失败：$WorkspacePath"
    }

    $tempInput = Join-Path $BuildDir "__generated.in"
    [System.IO.File]::WriteAllText($tempInput, ($generated -join [Environment]::NewLine) + [Environment]::NewLine, [System.Text.UTF8Encoding]::new($false))
    Write-Log "START validator generated data: $WorkspacePath"
    Write-Log "CMD   Get-Content $tempInput | & $validator"
    Get-Content -LiteralPath $tempInput | & $validator | Out-Host
    $exitCode = $LASTEXITCODE
    Write-Log "END   validator generated data: $WorkspacePath (exit=$exitCode)"
    if ($exitCode -ne 0) {
        throw "generator 产出的数据未通过 validator：$WorkspacePath"
    }
}

function Invoke-AnswerChecks {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath,

        [Parameter(Mandatory = $true)]
        [string]$BuildDir
    )

    $inputPath = Join-Path $WorkspacePath "testdata/1.in"
    $answerPath = Join-Path $WorkspacePath "testdata/1.out"
    if (-not (Test-Path -LiteralPath $answerPath)) {
        return
    }

    $solution = Get-BinaryPath -OutputDir $BuildDir -BaseName "STD"
    $checker = Get-BinaryPath -OutputDir $BuildDir -BaseName "CHECKER"

    $actualOutputPath = Join-Path $BuildDir "__std.out"
    Write-Log "[sample answer] $WorkspacePath"
    Get-Content -LiteralPath $inputPath | & $solution | Set-Content -LiteralPath $actualOutputPath
    if ($LASTEXITCODE -ne 0) {
        throw "标准程序执行失败：$WorkspacePath"
    }
    if ((Invoke-LoggedCommand -FilePath $checker -ArgumentList @($inputPath, $actualOutputPath, $answerPath) -Description "checker sample: $WorkspacePath") -ne 0) {
        throw "标准程序与样例输出不匹配：$WorkspacePath"
    }
}

function Test-OneWorkspace {
    param(
        [Parameter(Mandatory = $true)]
        [string]$WorkspacePath
    )

    Test-WorkspaceStructure -WorkspacePath $WorkspacePath
    $buildDir = Invoke-DirectBuild -WorkspacePath $WorkspacePath
    Invoke-ValidatorChecks -WorkspacePath $WorkspacePath -BuildDir $buildDir
    Invoke-AnswerChecks -WorkspacePath $WorkspacePath -BuildDir $buildDir
}

function Invoke-SmokeTest {
    $smokeNames = @(
        @{ Name = "codex-smoke-standard"; Interactive = $false },
        @{ Name = "codex-smoke-interactive"; Interactive = $true }
    )

    foreach ($item in $smokeNames) {
        $workspacePath = Join-Path $examplesRoot $item.Name
        if (Test-Path -LiteralPath $workspacePath) {
            Remove-Item -LiteralPath $workspacePath -Recurse -Force
        }

        try {
            Write-Log "[smoke:create] $($item.Name)"
            if ($item.Interactive) {
                & (Join-Path $PSScriptRoot "create-workspace.ps1") -Name $item.Name -Interactive | Out-Host
            } else {
                & (Join-Path $PSScriptRoot "create-workspace.ps1") -Name $item.Name | Out-Host
            }
            if ($LASTEXITCODE -ne 0) {
                throw "create-workspace 失败：$($item.Name)"
            }

            Test-OneWorkspace -WorkspacePath $workspacePath
        } finally {
            if (Test-Path -LiteralPath $workspacePath) {
                Remove-Item -LiteralPath $workspacePath -Recurse -Force
            }
        }
    }
}

Test-TemplateMarkers
$workspaceList = Resolve-WorkspaceList -Requested $Workspace
foreach ($workspacePath in $workspaceList) {
    Write-Log "[workspace] $workspacePath"
    Test-OneWorkspace -WorkspacePath $workspacePath
}

if (-not $SkipSmokeTest) {
    Write-Log "[smoke] enabled"
    Invoke-SmokeTest
}

Write-Log "All tests passed."
