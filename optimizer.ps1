Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ฟังก์ชันตรวจสอบสิทธิ์ Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    [System.Windows.Forms.MessageBox]::Show("กรุณาคลิกขวาที่ไฟล์นี้แล้วเลือก 'Run with PowerShell' ในฐานะ Administrator เท่านั้น!", "สิทธิ์ไม่เพียงพอ", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# สร้างหน้าต่างหลักของโปรแกรม
$form = New-Object System.Windows.Forms.Form
$form.Text = "ULTRAZNEX MULTI-TOOL OPTIMIZER v2.0"
$form.Size = New-Object System.Drawing.Size(550, 520)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(25, 25, 25) # พื้นหลังสีเทาเข้มสุดเท่
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# สร้างหัวข้อโลโก้ด้านบน (Header)
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = "ULTRAZNEX GAMING PERFORMANCE"
$headerLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$headerLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 128) # แสงสีเขียวเลเซอร์
$headerLabel.Size = New-Object System.Drawing.Size(500, 35)
$headerLabel.Location = New-Object System.Drawing.Point(25, 20)
$headerLabel.TextAlign = "Center"
$form.Controls.Add($headerLabel)

# แถบบรรยายสรรพคุณสั้นๆ
$subLabel = New-Object System.Windows.Forms.Label
$subLabel.Text = "OS Reference: Windows 10/11  |  Target: Lowest Input Latency"
$subLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$subLabel.ForeColor = [System.Drawing.Color]::Gray
$subLabel.Size = New-Object System.Drawing.Size(500, 20)
$subLabel.Location = New-Object System.Drawing.Point(25, 55)
$subLabel.TextAlign = "Center"
$form.Controls.Add($subLabel)

# กล่องข้อความแสดงสถานะด้านล่าง (Status Box)
$statusBox = New-Object System.Windows.Forms.Label
$statusBox.Text = "สถานะ: พร้อมใช้งาน (กรุณาเลือกกดปุ่มปรับแต่งเพื่อเริ่มทำงาน)"
$statusBox.Font = New-Object System.Drawing.Font("Tahoma", 9, [System.Drawing.FontStyle]::Bold)
$statusBox.ForeColor = [System.Drawing.Color]::White
$statusBox.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
$statusBox.Size = New-Object System.Drawing.Size(480, 40)
$statusBox.Location = New-Object System.Drawing.Point(25, 410)
$statusBox.TextAlign = "MiddleCenter"
$form.Controls.Add($statusBox)

# สไตล์ปุ่มกดส่วนกลางแบบโปรแกรมเกมเมอร์
function Create-Button($text, $x, $y, $color, $clickAction) {
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
    $btn.Add_Click($clickAction)
    $form.Controls.Add($btn)
}

# 1. Action สำหรับปุ่มปรับเครือข่าย
$netClick = {
    $statusBox.Text = "กำลังปรับแต่งระะบบเครือข่าย ^& DNS... กรุณารอสักครู่"
    $statusBox.ForeColor = [System.Drawing.Color]::Yellow
    [System.Windows.Forms.Application]::DoEvents()
    
    netsh int tcp set global autotuninglevel=normal
    netsh int tcp set global chimney=disabled
    netsh int tcp set global dca=enabled
    netsh int tcp set global netdma=enabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set global congestionprovider=ctcp
    netsh int tcp set global timestamps=disabled
    netsh int tcp set global rss=enabled
    netsh int tcp set global rsc=disabled
    netsh int tcp set global fastopen=enabled
    
    for /f "tokens=3*" %%i in ('netsh interface show interface ^| findstr "Connected"') do (
        netsh interface ip set dns name="%%j" source=static addr=1.1.1.1 register=primary
        netsh interface ip add dns name="%%j" addr=8.8.8.8 index=2
    )
    
    $statusBox.Text = "สำเร็จ! ปรับเครือข่ายลดปิงเรียบร้อยแล้ว"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 2. Action สำหรับปุ่มปรับ Input Lag
$sysClick = {
    $statusBox.Text = "กำลังปรับแต่่งความหน่วง Registry เครื่อง... กรุณารอสักครู่"
    $statusBox.ForeColor = [System.Drawing.Color]::Yellow
    [System.Windows.Forms.Application]::DoEvents()
    
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v PollingRate /t REG_DWORD /d 1000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v PollingRate /t REG_DWORD /d 1000 /f
    bcdedit /set useplatformclock false
    bcdedit /set disabledynamictick yes
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
    
    $statusBox.Text = "สำเร็จ! ปรับแต่งระบบและลดอาการหน่วงคีย์บอร์ด/เมาส์แล้ว"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 3. Action สำหรับปุ่มจัดเต็มรันทั้งหมด
$allClick = {
    $statusBox.Text = "กำลังทำงานขั้นสูง + ติดตั้งสกีมพลังงาน ULTRAZNEX..."
    $statusBox.ForeColor = [System.Drawing.Color]::Orange
    [System.Windows.Forms.Application]::DoEvents()
    
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -changename e9a42b02-d5df-448d-aa00-03f14749eb61 "ULTRAZNEX" "Custom Gaming Power Plan for Maximum Performance"
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    
    & $netClick
    & $sysClick
    
    $statusBox.Text = "เต็มระบบสำเร็จ! แนะนำให้รีสตาร์ทคอมพิวเตอร์ของคุณ 1 ครั้ง"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 4. Action สำหรับปุ่มล้างไฟล์ขยะ
$cleanClick = {
    $statusBox.Text = "กำลังเคลียร์แคชระบบและลบไฟล์ Temp ขยะในเครื่อง..."
    $statusBox.ForeColor = [System.Drawing.Color]::Yellow
    [System.Windows.Forms.Application]::DoEvents()
    
    ipconfig /flushdns
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    $statusBox.Text = "ล้างหน่วยความจำแคชและลบไฟล์ขยะเสร็จสมบูรณ์!"
    $statusBox.ForeColor = [System.Drawing.Color]::Lime
}

# 5. Action สำหรับปุ่มคืนค่าเดิมโรงงาน
$restoreClick = {
    $result = [System.Windows.Forms.MessageBox]::Show("คุณแน่ใจใช่หรือไม่ที่จะลบแผน ULTRAZNEX และดึงค่าดั้งเดิมของ Windows กลับคืนมาทั้งหมด?", "ยืนยันการคืนค่าเดิม", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($result -eq "Yes") {
        $statusBox.Text = "กำลังถอนการตั้งค่าทั้งหมดและดึงค่าเดิมของ Microsoft..."
        $statusBox.ForeColor = [System.Drawing.Color]::Red
        [System.Windows.Forms.Application]::DoEvents()
        
        netsh int tcp reset
        netsh int ip reset
        reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 1 /f
        powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
        powercfg -delete e9a42b02-d5df-448d-aa00-03f14749eb61
        bcdedit /deletevalue useplatformclock
        
        $statusBox.Text = "คืนค่าเริ่มต้นโรงงานเสร็จสิ้นแล้ว! แนะนำให้รีบูตระบบ"
        $statusBox.ForeColor = [System.Drawing.Color]::Cyan
    }
}

# วาดปุ่มกดลงบนหน้าต่างแอปพลิเคชันแยกตามหน้าที่และสีสัน
Create-Button "🌐 OPTIMIZE NETWORK & DNS (ลดค่าปิง)" 25 90 [System.Drawing.Color]::FromArgb(40, 80, 180) $netClick
Create-Button "⚡ OPTIMIZE INPUT LAG (ลดความหน่วงอุปกรณ์)" 25 150 [System.Drawing.Color]::FromArgb(120, 40, 180) $sysClick
Create-Button "🔥 RUN ALL TWEAKS + APPLY ULTRAZNEX PLAN (จัดเต็มทุกฟังก์ชัน)" 25 210 [System.Drawing.Color]::FromArgb(230, 90, 10) $allClick
Create-Button "🧹 CLEAN JUNK & FLUSH DNS (ล้างไฟล์ขยะเบาเครื่อง)" 25 270 [System.Drawing.Color]::FromArgb(80, 120, 40) $cleanClick
Create-Button "⏪ RESTORE TO WINDOWS DEFAULTS (ถอนสคริปต์กลับค่าเดิม)" 25 330 [System.Drawing.Color]::FromArgb(150, 30, 30) $restoreClick

# แสดงผลหน้าจอแอปพลิเคชัน
$form.ShowDialog()
