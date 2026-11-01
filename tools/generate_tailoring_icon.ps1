Add-Type -AssemblyName System.Drawing

$out = "C:\Projects\TailoringManagementSystem\assets\images\app_icon.png"
$size = 1024

$bmp = New-Object System.Drawing.Bitmap($size, $size)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Background gradient: violet
$c1 = [System.Drawing.Color]::FromArgb(124, 58, 237)
$c2 = [System.Drawing.Color]::FromArgb(76, 29, 149)
$r0 = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($r0, $c1, $c2, [float]45)

# Rounded rect background
$rad = 200
$gp = New-Object System.Drawing.Drawing2D.GraphicsPath
$gp.AddArc(0, 0, $rad, $rad, 180, 90)
$gp.AddArc(($size - $rad), 0, $rad, $rad, 270, 90)
$gp.AddArc(($size - $rad), ($size - $rad), $rad, $rad, 0, 90)
$gp.AddArc(0, ($size - $rad), $rad, $rad, 90, 90)
$gp.CloseFigure()
$g.FillPath($brush, $gp)

# White needle drawing: use a simple tailor needle + thread symbolism
$wb  = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$wp  = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 28)
$wp.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$wp.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round

# Needle body (long diagonal line)
$g.DrawLine($wp, 240, 800, 760, 260)

# Needle eye hole: small ellipse near top
$eyeRect = New-Object System.Drawing.Rectangle(700, 200, 72, 105)
$g.DrawEllipse($wp, $eyeRect)
# Thread coming out of eye
$wp2 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 14)
$wp2.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dot
$g.DrawBezier($wp2, 736, 250, 820, 320, 820, 500, 760, 620)

# Scissors blades crossing lower-left area
$wp3 = New-Object System.Drawing.Pen([System.Drawing.Color]::White, 22)
$wp3.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$wp3.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
# Blade 1: bottom-left to mid-right (going up)
$g.DrawLine($wp3, 180, 750, 520, 530)
# Blade 2: bottom-right to mid-left
$g.DrawLine($wp3, 420, 780, 520, 530)
# Ring 1
$g.DrawEllipse($wp3, 100, 660, 110, 110)
# Ring 2
$g.DrawEllipse($wp3, 340, 680, 110, 110)

$bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()

Write-Host "Done: $out"
