<# Functions #>
# Wipe network stack.
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

# Restart printer spooler.
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

# Update group policies.
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

# Success dialog.
Function ShowSuccessDialog {
    [System.Windows.Forms.MessageBox]::Show("Operation completed successfully", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}

# Error dialog.
Function ShowErrorDialog {
    [System.Windows.Forms.MessageBox]::Show("An error has occurred", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
}

<# UI #>
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public class ProcessDPI {
    [DllImport("user32.dll", SetLastError=true)]
    public static extern bool SetProcessDPIAware();      
}
'@
$null = [ProcessDPI]::SetProcessDPIAware()
[System.Windows.Forms.Application]::EnableVisualStyles();

# Main form.
$form = New-Object System.Windows.Forms.Form
$form.Text = 'SD Helper'
$form.Size = New-Object System.Drawing.Size(255, 450)
$form.StartPosition = 'CenterScreen'
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
$form.MaximizeBox = $false

# System actions group box.
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Point(10,10)
$groupBox.Size = New-Object System.Drawing.Size(220,150) # Adjust size as needed
$groupBox.Text = 'System Actions'

# Creates a button and binds it to an action.
function CreateButton($text, $pointY, $clickAction) {
    $button = New-Object System.Windows.Forms.Button
    $button.Location = New-Object System.Drawing.Point(110, $pointY)
    $button.Size = New-Object System.Drawing.Size(90, 25)
    $button.Text = $text
    $button.Add_Click($clickAction)
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::System
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    $form.Controls.Add($button)
}

CreateButton 'Clear' 30 { ClearNetworkStack }
CreateButton 'Clear' 60 { ClearChromeCache }
CreateButton 'Restart' 90 { RestartSpooler }
CreateButton 'Update' 120 { UpdateGP }

# List of all functions.
$functions = @("Network stack", "Chrome cache", "Printer Service", "Group Policy")

# Create labels.
$yPos = 25
foreach ($function in $functions) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, $yPos)  # Adjust the X position inside the group box
    $label.Size = New-Object System.Drawing.Size(90, 25)  # Adjust size as needed
    $label.Text = $function
    $groupBox.Controls.Add($label)  # Add label to the group box instead of the form
    $yPos += 30
}

# Add buttons to system actions groupbox.
$groupBox.Controls.Add($clearNetworkStackButton)
$groupBox.Controls.Add($clearCacheButton)
$groupBox.Controls.Add($RestartSpoolerButton)
$groupBox.Controls.Add($UpdateGPButton)

# Add groupbox to form.
$form.Controls.Add($groupBox)

# Create a label pair.
function CreateLabelPair($groupBox, $labelText, $valueText, $locationY) {
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, $locationY)
    $label.Size = New-Object System.Drawing.Size(70, 30)
    $label.Text = $labelText
    $groupBox.Controls.Add($label)

    $valueLabel = New-Object System.Windows.Forms.Label
    $valueLabel.Location = New-Object System.Drawing.Point(80, $locationY)
    $valueLabel.Size = New-Object System.Drawing.Size(130, 30)
    $valueLabel.Text = $valueText
    $groupBox.Controls.Add($valueLabel)
}

# Create the second group box for the label and value.
$infoGroupBox = New-Object System.Windows.Forms.GroupBox
$infoGroupBox.Location = New-Object System.Drawing.Point(10, 170) 
$infoGroupBox.Size = New-Object System.Drawing.Size(220, 230)
$infoGroupBox.Text = 'System Info'

# Hostname label pair.
CreateLabelPair $infoGroupBox 'Hostname:' $env:COMPUTERNAME 20

# Username label pair.
CreateLabelPair $infoGroupBox 'Username:' $env:UserName 50

# Operating System label pair.
$os = Get-WmiObject -Class Win32_OperatingSystem
CreateLabelPair $infoGroupBox 'OS:' $os.Caption 80

# CPU label pair.
$cpu = Get-WmiObject -Class Win32_Processor
CreateLabelPair $infoGroupBox 'CPU:' $cpu.Name 120

# RAM label pair.
$ram = Get-WmiObject -Class Win32_ComputerSystem
CreateLabelPair $infoGroupBox 'RAM:' ('{0:N2} GB' -f ($ram.TotalPhysicalMemory / 1GB)) 160

# Uptime label pair.
$uptime = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem -ComputerName $computername).LastBootUpTime
$uptimeText = '{0} days {1} hours {2} minutes {3} seconds' -f $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds
CreateLabelPair $infoGroupBox 'Uptime:' $uptimeText 190

# Add the labels to the second group box.
$infoGroupBox.Controls.Add($hostnameLabel)
$infoGroupBox.Controls.Add($hostnameValue)
$infoGroupBox.Controls.Add($usernameLabel)
$infoGroupBox.Controls.Add($usernameValue)
$infoGroupBox.Controls.Add($osLabel)
$infoGroupBox.Controls.Add($osValue)
$infoGroupBox.Controls.Add($cpuLabel)
$infoGroupBox.Controls.Add($cpuValue)
$infoGroupBox.Controls.Add($ramLabel)
$infoGroupBox.Controls.Add($ramValue)
$infoGroupBox.Controls.Add($uptimeLabel)
$infoGroupBox.Controls.Add($uptimeValue)

# Add the second group box to the form.
$form.Controls.Add($infoGroupBox)

# Show the GUI.
$form.Topmost = $true
$form.ShowDialog()