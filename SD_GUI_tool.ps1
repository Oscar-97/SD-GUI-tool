# Content to clipboard with | clip

#https://stackoverflow.com/questions/44954592/how-to-write-output-to-powershell-gui-with-scripts

<# Functions #>

# Wipe network stack
Function ClearNetworkStack() {
    $ClearNetworkStackResult = Write-Host "Wiping network stack..." && ipconfig /release && ipconfig /flushdns && ipconfig /renew && netsh int ip reset && netsh winsock reset
    
    if ($?) {
        Write-Host "Successfully wiped!"
    }
    else {
        Write-Host "Wipe failed."
    }
}

# Clear cache for Chrome.
Function ClearChromeCache() {
    $ResultClearChromeCache = Write-Host "Clearing Chrome cache..." && Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -EA SilentlyContinue -Verbose
    
    if ($?) {
        Write-Host "Cleared!"
    }
    else {
        Write-Host "Clearing cache failed."
    }
}

#Restart printer spooler
Function RestartSpooler() {
   $ResultRestartSpooler = Write-Host "Restarting spooler..." && Restart-Service -Name Spooler && Write-Host "Restarted!"

   if ($?) {
       Write-Host "Restarted spooler!"
   }
    else {
        Write-Host "Restarting spooler failed!"
    }

}

#GPupdate
Function UpdateGP() {
    Write-Host "Updating GP..." && gpupdate /force && Write-Host "Updated!"
}

<# UI #>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function NewTextLabels () {

}

function NewButton () {
    
}

function MainDisplay() {
    
}

$form = New-Object System.Windows.Forms.Form
$form.Text = 'SD Helper'
$form.Size = New-Object System.Drawing.Size(240,240)
$form.StartPosition = 'CenterScreen'

$clearNetworkStackButton = New-Object System.Windows.Forms.Button
$clearNetworkStackButton.Location = New-Object System.Drawing.Point(100,15)
$clearNetworkStackButton.Size = New-Object System.Drawing.Size(90,25)
$clearNetworkStackButton.Text = 'Clear'
$clearNetworkStackButton.Add_Click({ClearNetworkStack})
$form.Controls.Add($clearNetworkStackButton)

$clearCacheButton = New-Object System.Windows.Forms.Button
$clearCacheButton.Location = New-Object System.Drawing.Point(100,45)
$clearCacheButton.Size = New-Object System.Drawing.Size(90,25)
$clearCacheButton.Text = 'Clear'
$clearCacheButton.Add_Click({ClearChromeCache})
$form.Controls.Add($clearCacheButton)

$RestartSpoolerButton = New-Object System.Windows.Forms.Button
$RestartSpoolerButton.Location = New-Object System.Drawing.Point(100,75)
$RestartSpoolerButton.Size = New-Object System.Drawing.Size(90,25)
$RestartSpoolerButton.Text = 'Restart'
$RestartSpoolerButton.Add_Click({RestartSpooler})
$form.Controls.Add($RestartSpoolerButton)

$UpdateGPButton = New-Object System.Windows.Forms.Button
$UpdateGPButton.Location = New-Object System.Drawing.Point(100,105)
$UpdateGPButton.Size = New-Object System.Drawing.Size(90,25)
$UpdateGPButton.Text = 'Update'
$UpdateGPButton.Add_Click({RestartSpooler})
$form.Controls.Add($UpdateGPButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(110,140)
$label.Size = New-Object System.Drawing.Size(90,25)
$hostName = $env:COMPUTERNAME
$label.Text = $hostName
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(110,170)
$label.Size = New-Object System.Drawing.Size(90,25)
$userName = $env:UserName
$label.Text = $userName
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,20)
$label.Size = New-Object System.Drawing.Size(90,25)
$label.Text = 'Network stack'
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,50)
$label.Size = New-Object System.Drawing.Size(90,25)
$label.Text = 'Chrome cache'
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,80)
$label.Size = New-Object System.Drawing.Size(90,25)
$label.Text = 'Printer Service'
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,110)
$label.Size = New-Object System.Drawing.Size(90,25)
$label.Text = 'Group Policy'
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,140)
$label.Size = New-Object System.Drawing.Size(90,25)
$label.Text = 'Hostname:'
$form.Controls.Add($label)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20,170)
$label.Size = New-Object System.Drawing.Size(90,25)
$label.Text = 'Username:'
$form.Controls.Add($label)

$form.Topmost = $true
$form.ShowDialog()