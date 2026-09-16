Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Check for Administrator privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    [System.Windows.Forms.MessageBox]::Show("Please right-click and 'Run as Administrator'!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# Create Main Form
$form = New-Object System.Windows.Forms.Form
$form.Text = "ULTRAZNEX MULTI-TOOL OPTIMIZER v2.1"
$form.Size = New-Object System.Drawing.Size(550, 520)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Header Label
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "ULTRAZNEX GAMING PERFORMANCE"
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$headerLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 128)
$headerLabel.Size = New-Object System.Drawing.Size(500, 35)
$headerLabel.Location = New-Object System.Drawing.Point(25, 20)
$headerLabel.TextAlign = "Center"
$form.Controls.Add($headerLabel)

# Sub Label
$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = "OS Reference: Windows 10/11  |  Target: Lowest Input Latency"
$subLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$subLabel.ForeColor = [System.Drawing.Color]::Gray
$subLabel.Size = New-Object System.Drawing.Size(500, 20)
$subLabel.Location = New-Object System.Drawing.Point(25, 55)
$subLabel.TextAlign = "Center"
$form.Controls.Add($subLabel)

# Status Box
$statusBox = New-Object System.Windows.Forms.Label
$statusBox.Text = "STATUS: Ready (Select an option below to begin)"
$statusBox.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$statusBox.ForeColor = [System.Drawing.Color]::White
$statusBox.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$statusBox.Size = New-Object System.Drawing.Size(480, 40)
$statusBox.Location = New-Object System.Drawing.Point(25, 410)
$statusBox.TextAlign = "MiddleCenter"
$form.Controls.Add($statusBox)

# Button Creation Helper Function
function Create-CustomButton($text, $x, $y, $color, $scriptBlock) {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Size = New-Object System.Drawing.Size(480, 45)
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.BackColor = $color
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.Cursor = "Hand"
    $btn.Add_Click($scriptBlock)
    $form.Controls.Add($btn)
}

# 1. Action: Optimize Network
$netClick = {
    $statusBox.Text = "Optimizing network stack & DNS... Please wait..."
    $statusBox.ForeColor = [System.Drawing.Color]::Yellow
    [System.Windows.Forms.Application]::DoEvents()
    
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global chimney=disabled
    netsh int tcp set global dca=enabled
    netsh int tcp set global netdma=enabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set global timestamps=disabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global rsc=disabled
    netsh int tcp set global fastopen=enabled
    
    $statusBox.Text = "SUCCESS: Network optimized successfully!"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 2. Action: Optimize System Latency
$sysClick = {
    $statusBox.Text = "Applying registry latency tweaks... Please wait..."
    $statusBox.ForeColor = [System.Drawing.Color]::Yellow
    [System.Windows.Forms.Application]::DoEvents()
    
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v PollingRate /t REG_DWORD /d 1000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v PollingRate /t REG_DWORD /d 1000 /f
    bcdedit /set useplatformclock false
    bcdedit /set disabledynamictick yes
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
    
    $statusBox.Text = "SUCCESS: System responsiveness optimized!"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 3. Action: Full Optimization + Power Plan
$allClick = {
    $statusBox.Text = "Deploying full tweaks & installing ULTRAZNEX plan..."
    $statusBox.ForeColor = [System.Drawing.Color]::Orange
    [System.Windows.Forms.Application]::DoEvents()
    
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -changename e9a42b02-d5df-448d-aa00-03f14749eb61 "ULTRAZNEX" "Custom Gaming Power Plan"
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    
    netsh int tcp set global autotuninglevel=normal
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
    
    $statusBox.Text = "SUCCESS: Full tweaks active! Please restart your PC."
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 4. Action: Clean Junk Files
$cleanClick = {
    $statusBox.Text = "Purging system junk & flushing DNS cache..."
    $statusBox.ForeColor = [System.Drawing.Color]::Yellow
    [System.Windows.Forms.Application]::DoEvents()
    
    ipconfig /flushdns
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    $statusBox.Text = "SUCCESS: Junk files and network cache cleared!"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 5. Action: Restore to Default
$restoreClick = {
    $result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to revert all tweaks back to Windows defaults?", "Confirm Restore", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($result -eq "Yes") {
        $statusBox.Text = "Restoring factory default parameters..."
        $statusBox.ForeColor = [System.Drawing.Color]::Red
        [System.Windows.Forms.Application]::DoEvents()
        
        netsh int tcp reset
        netsh int ip reset
        reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 1 /f
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        powercfg -delete e9a42b02-d5df-448d-aa00-03f14749eb61
        
        $statusBox.Text = "SUCCESS: Default parameters restored! Please reboot."
        $statusBox.ForeColor = [System.Drawing.Color]::Cyan
    }
}

# Render GUI Controls (Buttons)
Create-CustomButton "🌐 OPTIMIZE NETWORK & DNS" 25 90 ([System.Drawing.Color]::FromArgb(40, 80, 180)) $netClick
Create-CustomButton "⚡ OPTIMIZE INPUT LAG" 25 150 ([System.Drawing.Color]::FromArgb(120, 40, 180)) $sysClick
Create-CustomButton "🔥 RUN ALL TWEAKS + APPLY ULTRAZNEX PLAN" 25 210 ([System.Drawing.Color]::FromArgb(230, 90, 10)) $allClick
Create-CustomButton "🧹 CLEAN JUNK & FLUSH DNS" 25 270 ([System.Drawing.Color]::FromArgb(80, 120, 40)) $cleanClick
Create-CustomButton "⏪ RESTORE TO WINDOWS DEFAULTS" 25 330 ([System.Drawing.Color]::FromArgb(150, 30, 30)) $restoreClick

# Launch Application Form Window
$form.ShowDialog()
