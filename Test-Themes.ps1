[CmdletBinding()]
param(
    [string]$ThemeDirectory = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'
$expectedFiles = @(
    'Noir-Absolu.theme.css',
    'Noir-Absolu-Bleu.theme.css',
    'Noir-Absolu-Rouge.theme.css',
    'Noir-Absolu-Orange.theme.css',
    'Noir-Absolu-Jaune.theme.css',
    'Noir-Absolu-Vert.theme.css',
    'Noir-Absolu-Cyan.theme.css',
    'Noir-Absolu-Rose.theme.css'
)

$failures = [System.Collections.Generic.List[string]]::new()
$commonBodyHashes = [System.Collections.Generic.List[string]]::new()
$results = [System.Collections.Generic.List[object]]::new()

foreach ($fileName in $expectedFiles) {
    $path = Join-Path $ThemeDirectory $fileName
    if (-not (Test-Path -LiteralPath $path)) {
        $failures.Add("Fichier manquant : $fileName")
        continue
    }

    $text = [System.IO.File]::ReadAllText($path)
    $openBraces = ([regex]::Matches($text, '\{')).Count
    $closeBraces = ([regex]::Matches($text, '\}')).Count
    $name = [regex]::Match($text, '@name\s+([^\r\n]+)').Groups[1].Value
    $accent = [regex]::Match($text, '--noir-accent:\s*(#[0-9a-fA-F]{6})').Groups[1].Value

    $checks = [ordered]@{
        StartsWithMetadata = $text.StartsWith('/**')
        BilingualName = ($name -match '^Noir Absolu .+ - Absolute Black .+$')
        Version = ($text -match '@version\s+1\.1\.0')
        Author = ($text -match '@author\s+woozyfps\.')
        Website = (($text -match '@authorLink\s+https://wooptimisation\.pro') -and ($text -match '@website\s+https://wooptimisation\.pro'))
        TrueBlack = ($text -match '--noir-amoled:\s*#000000')
        AccessibleAccentText = (($text -match '--noir-on-accent:\s*#000000') -and ($text -match '--button-filled-brand-text:\s*var\(--noir-on-accent\)'))
        BalancedBraces = ($openBraces -eq $closeBraces)
        NoPlaceholders = -not ($text -match '\{\{[A-Z0-9_]+\}\}')
        GifPickerFix = (([regex]::Matches($text, '\[role="dialog"\]:not\(\[class\*="positionContainer_"\]\)')).Count -ge 3)
        NoBroadBackdrop = -not ($text -match '\[class\*="backdrop_"\]')
        NoForeignCredits = -not ($text -match 'LuckFire|Alexy|Codex|amoled-cord|@source')
    }

    foreach ($check in $checks.GetEnumerator()) {
        if (-not $check.Value) {
            $failures.Add("$fileName : échec $($check.Key)")
        }
    }

    $body = [regex]::Match($text, '(?s)/\*\r?\n \* Discord répartit ses couleurs.*$').Value.Replace("`r`n", "`n")
    if ([string]::IsNullOrWhiteSpace($body)) {
        $failures.Add("$fileName : corps CSS commun introuvable")
    }
    else {
        $bodyBytes = [System.Text.Encoding]::UTF8.GetBytes($body)
        $commonBodyHashes.Add([Convert]::ToHexString([System.Security.Cryptography.SHA256]::HashData($bodyBytes)))
    }

    $results.Add([pscustomobject]@{
        File = $fileName
        Name = $name
        Accent = $accent
        Braces = "$openBraces/$closeBraces"
        Valid = -not ($failures | Where-Object { $_ -like "$fileName :*" })
    })
}

if (($commonBodyHashes | Select-Object -Unique).Count -ne 1) {
    $failures.Add('Le corps CSS commun diffère entre les variantes.')
}

$results | Format-Table -AutoSize

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Error $_ }
    throw "$($failures.Count) validation(s) en échec."
}

Write-Output 'Validation réussie : 8 thèmes autonomes, synchronisés et sans régression connue.'
