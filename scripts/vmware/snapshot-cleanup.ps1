<#
   NOTES
   ===========================================================================
    Created with:  Visual Studio Code
    Created on:    4/24/2018
    Created by:    Calvin Kohler-Katz
    Organization:  
    Filename:      snapshot-cleanup\snapshot-cleanup.ps1
   ===========================================================================
   DESCRIPTION
       Remove snapshots older than a given date; skipping the exclusion list.
       Exclusion list is RegExp
#>

param(
    # vCenter Server
    [Parameter(Mandatory = $true)]
    [string]
    $vCenterServer,
    # Credential
    [Parameter(Mandatory = $true)]
    [System.Management.Automation.PSCredential]
    $Credential
)

# Set days to retain snapshot
$days = 7

# Set VM exclusion list
$vm_exclusion_list = @(
    "template",
    "replica",
    "_Master"
)

# Set Snapshot exclusion list
$snap_exclusion_list = @(
    "^veeam",
    "citrix",
    "replica",
    "^dnd"
)

$cutoff_date = (Get-Date).AddDays($days * -1)

function MatchExclusions ($vm_name, $exclusion_list) {
    $r = $false
    foreach ($item in $exclusion_list) {
        if ($vm_name -imatch $item) {
            $r = $true
        }
    }
    return $r
}

$vm_snap_list = @()
Connect-VIServer $vCenterServer -Credential $Credential | Out-Null

$vm_list = Get-VM | Where-Object {-not (MatchExclusions $_.Name $vm_exclusion_list) } | Sort-Object Name

foreach ($vm in $vm_list) {
    $vm_snap = $vm | Get-Snapshot | Where-Object {
        -not (MatchExclusions $_.Name $snap_exclusion_list) -and
        $_.Created -lt $cutoff_date }
    if ($vm_snap) {
        $vm_snap_list += $vm
    }
}

if ($vm_snap_list) {
    foreach ($vm in $vm_snap_list) {
        Write-Host ("Removing snapshot(s) from VM: " + $vm.Name)
        $vm_snap = $vm | Get-Snapshot | Where-Object {
            -not (MatchExclusions $_.Name $snap_exclusion_list) -and
            $_.Created -lt $cutoff_date } | Sort-Object Created -Descending
        if ($vm_snap) {
            Write-Host "Removing snapshot(s):"
            Write-Host $vm_snap
            $vm_snap | Remove-Snapshot -Confirm:$false | Out-Null
        }
    }
}
else {
    "No snapshots found."
}
Disconnect-VIServer -Confirm:$false