# Run on Windows machine with PowerCLI
# VMware.VumAutomation not compatible with PowerShell Core

param (
    # Cluster Name
    [Parameter(Mandatory = $true)]
    [string]
    $ClusterName,
    # vCenter Server
    [Parameter(Mandatory = $true)]
    [string]
    $vCenterServer,
    # Parameter help description
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $Credential
)

# Disable timeout
Set-PowerCLIConfiguration -Scope Session -WebOperationTimeoutSeconds -1 -Confirm:$false | Out-Null

# Connect VIServer
Connect-VIServer $vCenterServer -Credential $Credential | Out-Null

# Get cluster
$vmcluster = Get-Cluster -Name $ClusterName

# Scan the inventory first
$vmcluster | Test-Compliance

# Get non-compliant patch/extension baselines
$baselines = ($vmcluster | Get-Compliance -ComplianceStatus NotCompliant | `
        Select-Object -Unique Baseline).Baseline | `
    Where-Object {$_.BaselineType -notmatch 'Upgrade'} | `
    Sort-Object Name

# Remediate all baselines
foreach ($baseline in $baselines) {
    $vmcluster | Update-Entity -Confirm:$false `
        -Baseline $baseline `
        -ClusterDisableHighAvailability:$true `
        -ClusterDisableFaultTolerance:$true `
        -ClusterDisableDistributedPowerManagement:$true `
        -ClusterEnableParallelRemediation:$false
}
