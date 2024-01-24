<# Functions #>
# Wipe network stack
Function ClearNetworkStack {
    Write-Host "Wiping network stack..."

    ipconfig /release
    if (-not $?) { Write-Host "ipconfig /release failed"; return }

    ipconfig /flushdns
    if (-not $?) { Write-Host "ipconfig /flushdns failed"; return }

    ipconfig /renew
    if (-not $?) { Write-Host "ipconfig /renew failed"; return }

    netsh int ip reset
    if (-not $?) { Write-Host "netsh int ip reset failed"; return }

    netsh winsock reset
    if (-not $?) { Write-Host "netsh winsock reset failed"; return }

    Write-Host "Successfully wiped!"
    ShowSuccessDialog
}

# Clear cache for Chrome.
Function ClearChromeCache {
    Write-Host "Clearing Chrome cache..."

    Remove-Item -path "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache\*" -Recurse -Force -ErrorAction SilentlyContinue -Verbose

    if ($?) {
        Write-Host "Cleared!"
        ShowSuccessDialog
    }
    else {
        Write-Host "Clearing cache failed."
        ShowErrorDialog
    }
}

#Restart printer spooler
Function RestartSpooler {
    Write-Host "Restarting spooler..."

    Restart-Service -Name Spooler

    if ($?) {
        Write-Host "Restarted spooler!"
        ShowSuccessDialog
    }
    else {
        Write-Host "Restarting spooler failed!"
        ShowErrorDialog
    }
}

#GPupdate
Function UpdateGP {
    Write-Host "Updating GP..."

    gpupdate /force

    if ($?) {
        Write-Host "GP updated successfully!"
        ShowSuccessDialog
    }
    else {
        Write-Host "Failed to update GP."
        ShowErrorDialog
    }
}

# Success dialog
Function ShowSuccessDialog {
    [System.Windows.Forms.MessageBox]::Show("Operation completed successfully", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Error dialog
Function ShowErrorDialog {
    [System.Windows.Forms.MessageBox]::Show("An error has occurred", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

<# UI #>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'SD Helper'
$form.Size = New-Object System.Drawing.Size(230, 230)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# Clear Network Stack Button
$clearNetworkStackButton = New-Object System.Windows.Forms.Button
$clearNetworkStackButton.Location = New-Object System.Drawing.Point(105, 15)
$clearNetworkStackButton.Size = New-Object System.Drawing.Size(90, 25)
$clearNetworkStackButton.Text = 'Clear'
$clearNetworkStackButton.Add_Click({ ClearNetworkStack })
$form.Controls.Add($clearNetworkStackButton)

# Clear Chrome Cache Button
$clearCacheButton = New-Object System.Windows.Forms.Button
$clearCacheButton.Location = New-Object System.Drawing.Point(105, 45)
$clearCacheButton.Size = New-Object System.Drawing.Size(90, 25)
$clearCacheButton.Text = 'Clear'
$clearCacheButton.Add_Click({ ClearChromeCache })
$form.Controls.Add($clearCacheButton)

# Restart Printer Service Button
$RestartSpoolerButton = New-Object System.Windows.Forms.Button
$RestartSpoolerButton.Location = New-Object System.Drawing.Point(105, 75)
$RestartSpoolerButton.Size = New-Object System.Drawing.Size(90, 25)
$RestartSpoolerButton.Text = 'Restart'
$RestartSpoolerButton.Add_Click({ RestartSpooler })
$form.Controls.Add($RestartSpoolerButton)

# Update Group Policy Button
$UpdateGPButton = New-Object System.Windows.Forms.Button
$UpdateGPButton.Location = New-Object System.Drawing.Point(105, 105)
$UpdateGPButton.Size = New-Object System.Drawing.Size(90, 25)
$UpdateGPButton.Text = 'Update'
$UpdateGPButton.Add_Click({ UpdateGP })
$form.Controls.Add($UpdateGPButton)

# Hostname
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(105, 140)
$label.Size = New-Object System.Drawing.Size(90, 25)
$hostName = $env:COMPUTERNAME
$label.Text = $hostName
$form.Controls.Add($label)

# Username
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(105, 170)
$label.Size = New-Object System.Drawing.Size(90, 25)
$userName = $env:UserName
$label.Text = $userName
$form.Controls.Add($label)

# Labels for each function
$functions = @("Network stack", "Chrome cache", "Printer Service", "Group Policy", "Hostname:", "Username:")
$yPos = 20

foreach ($function in $functions) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(20, $yPos)
    $label.Size = New-Object System.Drawing.Size(90, 25)
    $label.Text = $function
    $form.Controls.Add($label)
    $yPos += 30
}

# Show the GUI
$form.Topmost = $true
$form.ShowDialog()