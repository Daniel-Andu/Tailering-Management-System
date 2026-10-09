# Creates app_icon.png using .NET drawing
# Run this script first, then run generate_icons.ps1

Add-Type -AssemblyName System.Drawing

$size = 1024
$bitmap = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bitmap)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Background gradient (purple)
$brush1 = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    [System.Drawing.Point]::new(0, 0),
    [System.Drawing.Point]::new($size, $size),
    [System.Drawing.Color]::FromArgb(255, 139, 92, 246),   # #8B5CF6
    [System.Drawing.Color]::FromArgb(255, 109, 40, 217)    # #6D28D9
)

# Draw rounded rectangle background
$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 220
$rect = [System.Drawing.Rectangle]::new(0, 0, $size, $size)
$path.AddArc($rect.X, $rect.Y, $radius*2, $radius*2, 180, 90)
$path.AddArc($rect.Right - $radius*2, $rect.Y, $radius*2, $radius*2, 270, 90)
$path.AddArc($rect.Right - $radius*2, $rect.Bottom - $radius*2, $radius*2, $radius*2, 0, 90)
$path.AddArc($rect.X, $rect.Bottom - $radius*2, $radius*2, $radius*2, 90, 90)
$path.CloseFigure()
$g.FillPath($brush1, $path)

# White pen for icons
$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 48)
$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$whiteBrush = [System.Drawing.Brushes]::White

# Center point
$cx = 512
$cy = 512

# === SCISSORS ===
# Left ring (top-left)
$g.DrawEllipse($pen, ($cx - 250), ($cy - 330), 150, 150)
# Right ring (top-right)
$g.DrawEllipse($pen, ($cx + 100), ($cy - 330), 150, 150)

# Scissors blades crossing
$pen2 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 52)
$pen2.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$pen2.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
# Left blade: top-left to bottom-right
$g.DrawLine($pen2, ($cx - 155), ($cy - 220), ($cx + 130), ($cy + 80))
# Right blade: top-right to bottom-left
$g.DrawLine($pen2, ($cx + 155), ($cy - 220), ($cx - 130), ($cy + 80))

# Center pivot dot
$pivotPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 139, 92, 246), 18)
$g.FillEllipse($whiteBrush, ($cx - 32), ($cy - 50), 64, 64)
$g.DrawEllipse($pivotPen, ($cx - 32), ($cy - 50), 64, 64)

# === NEEDLE ===
$needlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 28)
$needlePen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$needlePen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
# Needle body
$g.DrawLine($needlePen, ($cx), ($cy + 130), ($cx + 10), ($cy + 340))
# Needle eye (ellipse)
$eyePen = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 22)
$g.DrawEllipse($eyePen, ($cx - 22), ($cy + 108), 44, 28)

# Thread
$threadPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 255, 255, 255), 16)
$threadPen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$threadPen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$threadPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$threadPath.AddBezier(
    [System.Drawing.Point]::new($cx + 10, $cy + 200),
    [System.Drawing.Point]::new($cx + 80, $cy + 240),
    [System.Drawing.Point]::new($cx + 50, $cy + 330),
    [System.Drawing.Point]::new($cx + 110, $cy + 380)
)
$g.DrawPath($threadPen, $threadPath)

# Save
$outPath = Join-Path $PSScriptRoot "assets\images\app_icon.png"
$bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bitmap.Dispose()

Write-Host "Icon created at: $outPath" -ForegroundColor Green
Write-Host "Size: 1024x1024 PNG" -ForegroundColor Cyan
