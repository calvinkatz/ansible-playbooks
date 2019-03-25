# Run on Windows machine with PowerCLI
# VMware.VumAutomation not compatible with PowerShell Core
# Only runs against Windows VMs, Linux use Open-VM-Tools

param(
    # VM Name
    [Parameter(Mandatory = $true)]
    [string]
    $VMName,
    # vCenter Server
    [Parameter(Mandatory = $true)]
    [string]
    $vCenterServer,
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $Credential
)

# Import PowerCLI Modules
#Import-Module VMware.PowerCLI
#Import-Module VMware.VumAutomation

# Disable timeout
Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds -1 -Confirm:$false | Out-Null

# Connect VIServer
Connect-VIServer $vCenterServer -Credential $Credential | Out-Null

# Get VM
$vm = Get-VM -Name $VMName

# Check Windows guest
if ($vm.Guest.GuestFamily -match 'windows') {
    # Check tools running and update needed
    if ($vm.Guest.ExtensionData.ToolsRunningStatus -eq 'guestToolsRunning' -and `
            $vm.Guest.ExtensionData.ToolsVersionStatus -eq 'guestToolsNeedUpgrade') {
        # Update tools
        Update-Tools -VM $vm
    }
}
