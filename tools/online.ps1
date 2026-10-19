[CmdletBinding()]
param(
    [switch]$PrepareOnly
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $repoRoot

$devecoRoot = if ([string]::IsNullOrWhiteSpace($env:DEVECO_HOME)) {
    Join-Path ${env:ProgramFiles} 'Huawei\DevEco Studio'
} else {
    $env:DEVECO_HOME
}
$hdcPath = if ([string]::IsNullOrWhiteSpace($env:HDC_BIN)) {
    Join-Path $devecoRoot 'sdk\default\openharmony\toolchains\hdc.exe'
} else {
    $env:HDC_BIN
}
$healthUrl = if ([string]::IsNullOrWhiteSpace($env:AUTH_API_HEALTH_URL)) {
    'http://127.0.0.1:3000/doc/swagger-api-json'
} else {
    $env:AUTH_API_HEALTH_URL
}
$selectedTarget = $env:HDC_TARGET

function Invoke-Hdc {
    param([string[]]$Arguments)

    $output = @(& $hdcPath @Arguments 2>&1)
    if ($LASTEXITCODE -ne 0) {
        throw "HDC command failed: $($Arguments -join ' ')"
    }
    return $output
}

function Test-ReverseMapping {
    param([object[]]$Lines)

    foreach ($line in $Lines) {
        $text = [string]$line
        if ($text -match '\[Reverse\]' -and $text -match 'tcp:3000\s+tcp:3000') {
            return $true
        }
    }
    return $false
}

try {
    if (-not (Test-Path -LiteralPath $hdcPath -PathType Leaf)) {
        throw "HDC was not found: $hdcPath. Set DEVECO_HOME or HDC_BIN."
    }

    try {
        Invoke-WebRequest -UseBasicParsing -Uri $healthUrl -TimeoutSec 5 | Out-Null
    } catch {
        throw "The word-api service is not reachable at $healthUrl. Start the course service and try again."
    }
    Write-Host "word-api is reachable: $healthUrl"

    $targetOutput = Invoke-Hdc @('list', 'targets')
    $onlineTargets = @(
        $targetOutput |
            ForEach-Object { ([string]$_).Trim() } |
            Where-Object { $_ -match '^[^\s]+:\d+$' }
    )

    if ([string]::IsNullOrWhiteSpace($selectedTarget)) {
        if ($onlineTargets.Count -eq 1) {
            $selectedTarget = $onlineTargets[0]
        } elseif ($onlineTargets.Count -gt 1) {
            throw "Multiple HDC targets are online; set HDC_TARGET to choose one: $($onlineTargets -join ', ')"
        }
    }
    if ([string]::IsNullOrWhiteSpace($selectedTarget)) {
        throw 'No online HDC target was found. Start the HarmonyOS emulator first.'
    }
    if ($onlineTargets -notcontains $selectedTarget) {
        throw "HDC target is not online: $selectedTarget"
    }
    Write-Host "HDC target: $selectedTarget"

    $forwarding = Invoke-Hdc @('-t', $selectedTarget, 'fport', 'ls')
    if (Test-ReverseMapping $forwarding) {
        Write-Host 'Reverse forwarding already exists: tcp:3000 -> tcp:3000'
    } else {
        [void](Invoke-Hdc @('-t', $selectedTarget, 'rport', 'tcp:3000', 'tcp:3000'))
        Write-Host 'Reverse forwarding created: tcp:3000 -> tcp:3000'
    }

    $forwarding = Invoke-Hdc @('-t', $selectedTarget, 'fport', 'ls')
    if (-not (Test-ReverseMapping $forwarding)) {
        throw 'HDC reverse forwarding was not registered successfully.'
    }

    if ($PrepareOnly) {
        Write-Host 'Forwarding prepared; application was not started.'
    } else {
        [void](Invoke-Hdc @('-t', $selectedTarget, 'shell', 'aa', 'start', '-a', 'EntryAbility', '-b', 'com.example.weixin'))
        Write-Host 'Application started: com.example.weixin'
    }
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
