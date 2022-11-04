# DAtum: 20221104 Author: B. Heine, J. Heine

class Workspace_Scan {
    [string]$WS_ID
    [System.DateTime]$ScanStartDate
    [System.DateTime]$ScanReadyDate
    [System.DateTime]$ScanResultRequestStartDate
    [System.DateTime]$ScanResultRequestEndDate
    [string]$Status
    [string]$ScanID
}

$global:WorspaceScans = @()
$global:MaxParallelScans = 2
$global:MaxScanRequestsPerH = 500
$global:MaxScanResultsPerH = 500
$global:MaxStatusRequestsPerH = 10000

function Get-ModifiedWorkspaces {
#$WorspaceScans = @()
    $Workspace_Scan1 = [Workspace_Scan]::new()
    $Workspace_Scan1.WS_ID = '01'
    $Workspace_Scan1.Status = 'W2S'
    $global:WorspaceScans += $Workspace_Scan1

    $Workspace_Scan2 = [Workspace_Scan]::new()
    $Workspace_Scan2.WS_ID = '02'
    $Workspace_Scan2.Status = 'W2S'
    $global:WorspaceScans += $Workspace_Scan2
    
    $Workspace_Scan3 = [Workspace_Scan]::new()
    $Workspace_Scan3.WS_ID = '03'
    $Workspace_Scan3.Status = 'W2S'
    $global:WorspaceScans += $Workspace_Scan3
}

function Get-WorkspacesCount {
    $global:WorspaceScans.count
}

function Get-WorkspacesCountW2s {
    $W2SCount = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'W2S') {
            $W2SCount += 1
        }
    }
    $W2SCount
}

function Get-WorkspacesCountWIS {
    $WISCount = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'WIS') {
            $WISCount += 1
        }
    }
    $WISCount
}

function Get-WorkspacesCountWSR {
    $WSRCount = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'WSR') {
            $WSRCount += 1
        }
    }
    $WSRCount
}

function Get-WorkspacesCountWRE {
    $WRECount = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'WRE') {
            $WRECount += 1
        }
    }
    $WRECount
}

function Get-WorkspacesCountWSReady {
    $WSReadyCount = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'WSReady') {
            $WSReadyCount += 1
        }
    }
    $WSReadyCount
}

function Get-WorkspacesStatistics {
    Write-Host 'Workspaces array statistics:'
    Write-Host '# Workspaces array :' $global:WorspaceScans.Count
    Write-Host '# W2S              :' $(Get-WorkspacesCountW2S)
    Write-Host '# WIS              :' $(Get-WorkspacesCountWIS)
    Write-Host '# WSR              :' $(Get-WorkspacesCountWSR)
    Write-Host '# WRE              :' $(Get-WorkspacesCountWRE)
    Write-Host '# WSReady          :' $(Get-WorkspacesCountWSReady)
}

function  Start-NextWorkspaceScan {
    $i = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'W2S') {
            Write-Host 'starting scan for workspace: ' $workspaceScan.WS_ID
            $global:WorspaceScans[$i].Status = 'WIS'
            $global:WorspaceScans[$i].ScanID = $(Get-Random)
            $global:WorspaceScans[$i].ScanStartDate = $(get-date)
            #API Call for $workspaceScan.WS_ID
            break
        }
        $i += 1
    }
}

function Get-ScanStatus {
    $i = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'WIS') {
            Write-Host 'starting status request for WS_ID  : ' $workspaceScan.WS_ID
            Write-Host 'starting status request for scanId : ' $workspaceScan.ScanID
            # API call for scan status
            $global:WorspaceScans[$i].Status = 'WSR'
            $global:WorspaceScans[$i].ScanReadyDate = get-date
        }
        $i += 1
    }
}

function Get-WorkspaceScanResults {
    $i = 0
    foreach ($workspaceScan in $global:WorspaceScans) {
        IF ($workspaceScan.Status -eq 'WSR') {
            Write-Host 'starting get scan results for WS_ID  : ' $workspaceScan.WS_ID
            Write-Host 'starting get scan results for scanId : ' $workspaceScan.ScanID
            $global:WorspaceScans[$i].Status = 'WRE'
            $global:WorspaceScans[$i].ScanResultRequestStartDate = get-date
            # API call for scan results
            Get-WorkspacesStatistics
            Start-Sleep -Seconds 1
            $global:WorspaceScans[$i].Status = 'WSReady'
            $global:WorspaceScans[$i].ScanResultRequestEndDate = get-date
            Get-WorkspacesStatistics
        }
        $i += 1
    }
}

#Main
Get-ModifiedWorkspaces
Get-WorkspacesStatistics

while ( $(Get-WorkspacesCount) -gt $(Get-WorkspacesCountWSReady)) {
    Start-Sleep -seconds 1
    Write-Host .
    while ($(Get-WorkspacesCountWIS) -lt $global:MaxParallelScans -and $(Get-WorkspacesCountW2s) -gt 0) { # und weniger als 500 Requests
   # if ($(Get-WorkspacesCountWIS) -lt $global:MaxParallelScans ) { # und weniger als 500 Requests

        Write-Host 'Starting next WorkspaceScan' 
        Start-NextWorkspaceScan          
        Get-WorkspacesStatistics      
    }
   # Wenn < 10000
   Get-ScanStatus
   Get-WorkspacesStatistics
   while ($(get-WorkspacesCountWSR) -gt 0) { # and < 500
        Get-WorkspaceScanResults
   } 
} 

#$WorspaceScans.Count