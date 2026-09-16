# เคลียร์ตัวแปรเก่าเพื่อป้องกันการค้างในความจำ
$form = $null

# ตรวจสอบสิทธิ์ Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Add-Type -AssemblyName System.Windows.Forms
    [System.Windows.Forms.MessageBox]::Show("กรุณารันคำสั่งนี้ในฐานะ Administrator เท่านั้น!", "สิทธิ์ไม่เพียงพอ", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# โหลดโมดูลสำหรับวาดหน้าต่างยุคใหม่
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase

# ออกแบบหน้าต่างรูปแบบโมเดิร์นด้วย XAML (WPF)
[xml]$xaml = @"
<Window xmlns="http://microsoft.com"
        xmlns:x="http://microsoft.com"
        Title="ULTRAZNEX MULTI-TOOL v3.0" Height="480" Width="520" 
        WindowStartupLocation="CenterScreen" Background="#1E1E1E" ResizeMode="NoResize">
    <StackPanel Margin="20">
        <!-- Header -->
        <TextBlock Text="ULTRAZNEX GAMING PERFORMANCE" FontSize="18" FontWeight="Bold" Foreground="#00FF80" HorizontalAlignment="Center" Margin="0,0,0,5"/>
        <TextBlock Text="OS Preference: Windows 10 / 11  |  Target: Lowest Input Latency" FontSize="10" Foreground="Gray" HorizontalAlignment="Center" Margin="0,0,0,20"/>
        
        <!-- Buttons Group -->
        <Button Name="BtnNet" Content="🌐 OPTIMIZE NETWORK &amp; DNS" Height="42" Background="#2850B4" Foreground="White" FontWeight="Bold" FontSize="11" Margin="0,5" Cursor="Hand"/>
        <Button Name="BtnSys" Content="⚡ OPTIMIZE INPUT LAG" Height="42" Background="#7828B4" Foreground="White" FontWeight="Bold" FontSize="11" Margin="0,5" Cursor="Hand"/>
        <Button Name="BtnAll" Content="🔥 RUN ALL TWEAKS + APPLY ULTRAZNEX PLAN" Height="42" Background="#E65A0A" Foreground="White" FontWeight="Bold" FontSize="11" Margin="0,5" Cursor="Hand"/>
        <Button Name="BtnClean" Content="🧹 CLEAN JUNK &amp; FLUSH DNS" Height="42" Background="#507828" Foreground="White" FontWeight="Bold" FontSize="11" Margin="0,5" Cursor="Hand"/>
        <Button Name="BtnRestore" Content="⏪ RESTORE TO WINDOWS DEFAULTS" Height="42" Background="#961E1E" Foreground="White" FontWeight="Bold" FontSize="11" Margin="0,5,0,25" Cursor="Hand"/>
        
        <!-- Status Box -->
        <Border Background="#282828" CornerRadius="3" Padding="10">
            <TextBlock Name="TxtStatus" Text="STATUS: Ready (Select an option above to begin)" Foreground="White" FontWeight="Bold" FontSize="11" HorizontalAlignment="Center"/>
        </Border>
    </StackPanel>
</Window>
"@

# อ่านโครงสร้างหน้าต่างเข้าสู่หน่วยความจำ
$reader = New-Object System.Xml.XmlNodeReader $xaml
$form = [Windows.Markup.XamlReader]::Load($reader)

# ดึงรายชื่อปุ่มควบคุมมาผูกกับโค้ดทำงาน
$BtnNet = $form.FindName("BtnNet")
$BtnSys = $form.FindName("BtnSys")
$BtnAll = $form.FindName("BtnAll")
$BtnClean = $form.FindName("BtnClean")
$BtnRestore = $form.FindName("BtnRestore")
$TxtStatus = $form.FindName("TxtStatus")

# --- ส่วนคำสั่งการทำงานเมื่อกดปุ่ม ---

$BtnNet.Add_Click({
    $TxtStatus.Text = "Optimizing network stack & DNS... Please wait..."
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
    
    $TxtStatus.Text = "SUCCESS: Network optimized successfully!"
})

$BtnSys.Add_Click({
    $TxtStatus.Text = "Applying registry latency tweaks... Please wait..."
    [System.Windows.Forms.Application]::DoEvents()
    
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\kbdhid\Parameters" /v PollingRate /t REG_DWORD /d 1000 /f
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\mouhid\Parameters" /v PollingRate /t REG_DWORD /d 1000 /f
    bcdedit /set useplatformclock false
    bcdedit /set disabledynamictick yes
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f
    
    $TxtStatus.Text = "SUCCESS: System responsiveness optimized!"
})

$BtnAll.Add_Click({
    $TxtStatus.Text = "Deploying full tweaks & installing ULTRAZNEX plan..."
    [System.Windows.Forms.Application]::DoEvents()
    
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    powercfg -changename e9a42b02-d5df-448d-aa00-03f14749eb61 "ULTRAZNEX" "Custom Gaming Power Plan"
    powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61
    
    netsh int tcp set global autotuninglevel=normal
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
    
    $TxtStatus.Text = "SUCCESS: Full tweaks active! Please restart your PC."
})

$BtnClean.Add_Click({
    $TxtStatus.Text = "Purging system junk & flushing DNS cache..."
    [System.Windows.Forms.Application]::DoEvents()
    
    ipconfig /flushdns
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    
    $TxtStatus.Text = "SUCCESS: Junk files and network cache cleared!"
})

$BtnRestore.Add_Click({
    $TxtStatus.Text = "Restoring factory default parameters..."
    [System.Windows.Forms.Application]::DoEvents()
    
    netsh int tcp reset
    netsh int ip reset
    reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 1 /f
    powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e
    powercfg -delete e9a42b02-d5df-448d-aa00-03f14749eb61
    
    $TxtStatus.Text = "SUCCESS: Default parameters restored! Please reboot."
})

# เปิดแสดงผลหน้าต่างโปรแกรม
$form.ShowDialog() | Out-Null
