[CmdletBinding()]
param(
    [string]$OutputDirectory = $PSScriptRoot
)

$ErrorActionPreference = 'Stop'

function Convert-HexToHsl {
    param([Parameter(Mandatory)][string]$Hex)

    $value = $Hex.TrimStart('#')
    if ($value.Length -ne 6) {
        throw "Couleur hexadécimale invalide : $Hex"
    }

    $red = [Convert]::ToInt32($value.Substring(0, 2), 16) / 255.0
    $green = [Convert]::ToInt32($value.Substring(2, 2), 16) / 255.0
    $blue = [Convert]::ToInt32($value.Substring(4, 2), 16) / 255.0
    $maximum = [Math]::Max($red, [Math]::Max($green, $blue))
    $minimum = [Math]::Min($red, [Math]::Min($green, $blue))
    $delta = $maximum - $minimum
    $lightness = ($maximum + $minimum) / 2.0

    if ($delta -eq 0) {
        $hue = 0.0
        $saturation = 0.0
    }
    else {
        $saturation = if ($lightness -gt 0.5) {
            $delta / (2.0 - $maximum - $minimum)
        }
        else {
            $delta / ($maximum + $minimum)
        }

        if ($maximum -eq $red) {
            $hue = (($green - $blue) / $delta) + $(if ($green -lt $blue) { 6.0 } else { 0.0 })
        }
        elseif ($maximum -eq $green) {
            $hue = (($blue - $red) / $delta) + 2.0
        }
        else {
            $hue = (($red - $green) / $delta) + 4.0
        }

        $hue /= 6.0
    }

    return '{0} {1}% {2}%' -f [Math]::Round($hue * 360), [Math]::Round($saturation * 100), [Math]::Round($lightness * 100)
}

$palettes = @(
    [ordered]@{
        File = 'Noir-Absolu.theme.css'; ColorFr = 'Violet'; ColorEn = 'Purple'
        Panel = '#030205'; Surface = '#08060d'; Raised = '#100c18'; RaisedHover = '#191226'; SurfaceHighest = '#21182e'
        Tooltip = '#181121'; ButtonHover = '#21182e'; ButtonActive = '#302044'
        BorderRgb = '190, 165, 255'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#a970ff'; AccentRgb = '169, 112, 255'; BrandHover = '#b985ff'; BrandActive = '#9557e6'
        Link = '#c29aff'; LinkRgb = '194, 154, 255'; LinkHover = '#e0ccff'
        Scrollbar = '#2d243a'; ScrollbarHover = '#4a3862'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    },
    [ordered]@{
        File = 'Noir-Absolu-Bleu.theme.css'; ColorFr = 'Bleu'; ColorEn = 'Blue'
        Panel = '#020305'; Surface = '#07090d'; Raised = '#0d1016'; RaisedHover = '#151a22'; SurfaceHighest = '#1b202a'
        Tooltip = '#141923'; ButtonHover = '#1d2430'; ButtonActive = '#273242'
        BorderRgb = '157, 178, 211'; BorderAlpha = '0.12'; BorderStrongAlpha = '0.20'
        Accent = '#52a8ff'; AccentRgb = '82, 168, 255'; BrandHover = '#76baff'; BrandActive = '#3a94ee'
        Link = '#69b4ff'; LinkRgb = '105, 180, 255'; LinkHover = '#9ad2ff'
        Scrollbar = '#252b35'; ScrollbarHover = '#394555'
        HoverAlpha = '0.07'; ActiveAlpha = '0.12'; SelectedAlpha = '0.18'; LinkUnderlineAlpha = '0.55'
        ReplyAlpha = '0.10'; MentionAlpha = '0.11'; MentionHoverAlpha = '0.16'; SelectionAlpha = '0.38'
    },
    [ordered]@{
        File = 'Noir-Absolu-Rouge.theme.css'; ColorFr = 'Rouge'; ColorEn = 'Red'
        Panel = '#050202'; Surface = '#0d0607'; Raised = '#180c0f'; RaisedHover = '#251216'; SurfaceHighest = '#30181e'
        Tooltip = '#211014'; ButtonHover = '#30181e'; ButtonActive = '#44212a'
        BorderRgb = '255, 135, 154'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#ff5c73'; AccentRgb = '255, 92, 115'; BrandHover = '#ff7a8d'; BrandActive = '#e84860'
        Link = '#ff879a'; LinkRgb = '255, 135, 154'; LinkHover = '#ffb3be'
        Scrollbar = '#3a2227'; ScrollbarHover = '#623640'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    },
    [ordered]@{
        File = 'Noir-Absolu-Orange.theme.css'; ColorFr = 'Orange'; ColorEn = 'Orange'
        Panel = '#050302'; Surface = '#0d0805'; Raised = '#181008'; RaisedHover = '#25180d'; SurfaceHighest = '#302014'
        Tooltip = '#22160c'; ButtonHover = '#302014'; ButtonActive = '#462d1a'
        BorderRgb = '255, 173, 102'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#ff8a3d'; AccentRgb = '255, 138, 61'; BrandHover = '#ffa163'; BrandActive = '#e6762f'
        Link = '#ffad66'; LinkRgb = '255, 173, 102'; LinkHover = '#ffd0a3'
        Scrollbar = '#3a2a20'; ScrollbarHover = '#624430'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    },
    [ordered]@{
        File = 'Noir-Absolu-Jaune.theme.css'; ColorFr = 'Jaune'; ColorEn = 'Yellow'
        Panel = '#050502'; Surface = '#0d0c05'; Raised = '#181609'; RaisedHover = '#25220e'; SurfaceHighest = '#302c16'
        Tooltip = '#221f0c'; ButtonHover = '#302c16'; ButtonActive = '#463f1e'
        BorderRgb = '255, 224, 102'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#f2c94c'; AccentRgb = '242, 201, 76'; BrandHover = '#ffda65'; BrandActive = '#d8ad32'
        Link = '#ffe066'; LinkRgb = '255, 224, 102'; LinkHover = '#fff0a3'
        Scrollbar = '#38351f'; ScrollbarHover = '#5c572f'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    },
    [ordered]@{
        File = 'Noir-Absolu-Vert.theme.css'; ColorFr = 'Vert'; ColorEn = 'Green'
        Panel = '#020503'; Surface = '#050d08'; Raised = '#09180f'; RaisedHover = '#0e2517'; SurfaceHighest = '#15301f'
        Tooltip = '#0c2115'; ButtonHover = '#15301f'; ButtonActive = '#1d462d'
        BorderRgb = '100, 230, 163'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#39d98a'; AccentRgb = '57, 217, 138'; BrandHover = '#5ee6a1'; BrandActive = '#24bf73'
        Link = '#64e6a3'; LinkRgb = '100, 230, 163'; LinkHover = '#a4f3c8'
        Scrollbar = '#21382b'; ScrollbarHover = '#35604a'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    },
    [ordered]@{
        File = 'Noir-Absolu-Cyan.theme.css'; ColorFr = 'Cyan'; ColorEn = 'Cyan'
        Panel = '#020505'; Surface = '#050c0d'; Raised = '#091719'; RaisedHover = '#0e2326'; SurfaceHighest = '#152e31'
        Tooltip = '#0c2023'; ButtonHover = '#152e31'; ButtonActive = '#1d4247'
        BorderRgb = '94, 231, 242'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#35d0e6'; AccentRgb = '53, 208, 230'; BrandHover = '#5bdfee'; BrandActive = '#1bb6cb'
        Link = '#5ee7f2'; LinkRgb = '94, 231, 242'; LinkHover = '#a7f5fa'
        Scrollbar = '#20373a'; ScrollbarHover = '#345c61'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    },
    [ordered]@{
        File = 'Noir-Absolu-Rose.theme.css'; ColorFr = 'Rose'; ColorEn = 'Pink'
        Panel = '#050204'; Surface = '#0d060a'; Raised = '#180a13'; RaisedHover = '#25101e'; SurfaceHighest = '#301628'
        Tooltip = '#220f1c'; ButtonHover = '#301628'; ButtonActive = '#461f3a'
        BorderRgb = '255, 145, 208'; BorderAlpha = '0.14'; BorderStrongAlpha = '0.24'
        Accent = '#ff5fb2'; AccentRgb = '255, 95, 178'; BrandHover = '#ff7fc2'; BrandActive = '#e7479c'
        Link = '#ff91d0'; LinkRgb = '255, 145, 208'; LinkHover = '#ffc0e4'
        Scrollbar = '#3a2130'; ScrollbarHover = '#61364f'
        HoverAlpha = '0.08'; ActiveAlpha = '0.14'; SelectedAlpha = '0.22'; LinkUnderlineAlpha = '0.60'
        ReplyAlpha = '0.12'; MentionAlpha = '0.13'; MentionHoverAlpha = '0.19'; SelectionAlpha = '0.42'
    }
)

$templatePath = Join-Path $PSScriptRoot 'Noir-Absolu.template.css'
$template = [System.IO.File]::ReadAllText($templatePath)
[System.IO.Directory]::CreateDirectory($OutputDirectory) | Out-Null
$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)

foreach ($palette in $palettes) {
    $values = [ordered]@{
        COLOR_FR = $palette.ColorFr
        COLOR_EN = $palette.ColorEn
        COLOR_FR_LOWER = $palette.ColorFr.ToLowerInvariant()
        COLOR_EN_LOWER = $palette.ColorEn.ToLowerInvariant()
        PANEL = $palette.Panel
        SURFACE = $palette.Surface
        RAISED = $palette.Raised
        RAISED_HOVER = $palette.RaisedHover
        SURFACE_HIGHEST = $palette.SurfaceHighest
        TOOLTIP = $palette.Tooltip
        BUTTON_HOVER = $palette.ButtonHover
        BUTTON_ACTIVE = $palette.ButtonActive
        BORDER_RGB = $palette.BorderRgb
        BORDER_ALPHA = $palette.BorderAlpha
        BORDER_STRONG_ALPHA = $palette.BorderStrongAlpha
        ACCENT_RGB = $palette.AccentRgb
        LINK_RGB = $palette.LinkRgb
        HOVER_ALPHA = $palette.HoverAlpha
        ACTIVE_ALPHA = $palette.ActiveAlpha
        SELECTED_ALPHA = $palette.SelectedAlpha
        ACCENT = $palette.Accent
        LINK = $palette.Link
        LINK_HOVER = $palette.LinkHover
        BRAND_HOVER = $palette.BrandHover
        BRAND_ACTIVE = $palette.BrandActive
        ACCENT_HSL = Convert-HexToHsl $palette.Accent
        BRAND_HOVER_HSL = Convert-HexToHsl $palette.BrandHover
        BRAND_ACTIVE_HSL = Convert-HexToHsl $palette.BrandActive
        SCROLLBAR = $palette.Scrollbar
        SCROLLBAR_HOVER = $palette.ScrollbarHover
        MENTION_ALPHA = $palette.MentionAlpha
        MENTION_HOVER_ALPHA = $palette.MentionHoverAlpha
        LINK_UNDERLINE_ALPHA = $palette.LinkUnderlineAlpha
        REPLY_ALPHA = $palette.ReplyAlpha
        SELECTION_ALPHA = $palette.SelectionAlpha
    }

    $content = $template
    foreach ($entry in $values.GetEnumerator()) {
        $content = $content.Replace("{{$($entry.Key)}}", [string]$entry.Value)
    }

    if ($content -match '\{\{[A-Z0-9_]+\}\}') {
        throw "Jeton non remplacé dans $($palette.File) : $($Matches[0])"
    }

    $destination = Join-Path $OutputDirectory $palette.File
    [System.IO.File]::WriteAllText($destination, $content, $utf8WithoutBom)
    Write-Output "Généré : $destination"
}
