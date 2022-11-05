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

$global:WorkspaceScans = @()
$global:LoopSleepSeconds = 5
$global:MaxParallelScans = 2
$global:MaxScanRequestsPerH = 2 #500
$global:MaxStatusRequestsPerH = 10000
$global:MaxScanResultsPerH = 500
$global:WorkspaceStatusRequestDates = @()


function Get-ModifiedWorkspaces {
#$WorspaceScans = @()
    $Workspace_Scan1 = [Workspace_Scan]::new()
    $Workspace_Scan1.WS_ID = '01'
    $Workspace_Scan1.Status = 'W2S'
    $global:WorkspaceScans += $Workspace_Scan1

    $Workspace_Scan2 = [Workspace_Scan]::new()
    $Workspace_Scan2.WS_ID = '02'
    $Workspace_Scan2.Status = 'W2S'
    $global:WorkspaceScans += $Workspace_Scan2
    
    $Workspace_Scan3 = [Workspace_Scan]::new()
    $Workspace_Scan3.WS_ID = '03'
    $Workspace_Scan3.Status = 'W2S'
    $global:WorkspaceScans += $Workspace_Scan3
}

function Get-WorkspacesCount {
    $global:WorkspaceScans.count
}

function Get-WorkspacesCountW2s {
    $W2SCount = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'W2S') {
            $W2SCount += 1
        }
    }
    $W2SCount
}

function Get-WorkspacesCountWIS {
    $WISCount = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'WIS') {
            $WISCount += 1
        }
    }
    $WISCount
}

function Get-WorkspacesCountWSR {
    $WSRCount = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'WSR') {
            $WSRCount += 1
        }
    }
    $WSRCount
}

function Get-WorkspacesCountWRE {
    $WRECount = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'WRE') {
            $WRECount += 1
        }
    }
    $WRECount
}

function Get-WorkspacesCountWSReady {
    $WSReadyCount = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'WSReady') {
            $WSReadyCount += 1
        }
    }
    $WSReadyCount
}

function Get-WorkspacesStatistics {
    Write-Host 'Workspaces array statistics:'
    Write-Host '# Workspaces array    :' $global:WorkspaceScans.Count
    Write-Host '# W2S                 :' $(Get-WorkspacesCountW2S)
    Write-Host '# WIS                 :' $(Get-WorkspacesCountWIS)
    Write-Host '# WSR                 :' $(Get-WorkspacesCountWSR)
    Write-Host '# WRE                 :' $(Get-WorkspacesCountWRE)
    Write-Host '# WSReady             :' $(Get-WorkspacesCountWSReady)
    Write-Host '# ScanRequestsLastH   :' $(Get-ScanRequestCountLastH) '/' $global:MaxScanRequestsPerH
    Write-Host '# StatusRequestsLastH :' $(Get-StatusRequestCountLastH) '/' $global:MaxStatusRequestsPerH
    Write-Host '# ResultFetchesLastH  :' $(Get-ResultFetchesCountLastH) '/' $global:MaxScanResultsPerH
}

function  Start-NextWorkspaceScan {
    $i = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'W2S') {
            Write-Host 'starting scan for workspace: ' $workspaceScan.WS_ID
            $global:WorkspaceScans[$i].Status = 'WIS'
            $global:WorkspaceScans[$i].ScanID = $(Get-Random)
            $global:WorkspaceScans[$i].ScanStartDate = $(get-date)
            #API Call for $workspaceScan.WS_ID
            break
        }
        $i += 1
    }
}

function Get-ScanStatus {
    $i = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'WIS') {
            Write-Host 'starting status request for WS_ID  : ' $workspaceScan.WS_ID
            Write-Host 'starting status request for scanId : ' $workspaceScan.ScanID
            $global:WorkspaceStatusRequestDates += Get-Date
            # API call for scan status
            $global:WorkspaceScans[$i].Status = 'WSR'
            $global:WorkspaceScans[$i].ScanReadyDate = get-date
        }
        $i += 1
    }
}

function Get-WorkspaceScanResults {
    $i = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.Status -eq 'WSR') {
            Write-Host 'starting get scan results for WS_ID  : ' $workspaceScan.WS_ID
            Write-Host 'starting get scan results for scanId : ' $workspaceScan.ScanID
            $global:WorkspaceScans[$i].Status = 'WRE'
            $global:WorkspaceScans[$i].ScanResultRequestStartDate = get-date
            # API call for scan results
            Get-WorkspacesStatistics
            Start-Sleep -Seconds 1
            $global:WorkspaceScans[$i].Status = 'WSReady'
            $global:WorkspaceScans[$i].ScanResultRequestEndDate = get-date
            Get-WorkspacesStatistics
        }
        $i += 1
    }
}

function Get-ScanRequestCountLastH {
    $DateLastH = $(Get-date).AddHours(-1)
    #$DateLastH = $(Get-date).AddSeconds(-20)
    $i = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.ScanStartDate -ge $DateLastH) {
            $i += 1  
        }
    }
    $i  
}

function Get-ResultFetchesCountLastH {
    $DateLastH = $(Get-date).AddHours(-1)
    $i = 0
    foreach ($workspaceScan in $global:WorkspaceScans) {
        IF ($workspaceScan.ScanResultRequestStartDate -ge $DateLastH) {
            $i += 1  
        }
    }
    $i  
}

function Get-StatusRequestCountLastH {
    $DateLastH = $(Get-date).AddHours(-1)
    $i = 0
    foreach ($WorkspaceStatusRequestDate in $global:WorkspaceStatusRequestDates) {
        IF ($WorkspaceStatusRequestDate -ge $DateLastH) {
            $i += 1  
        }
    }
    $i  
}

#Main
Get-ModifiedWorkspaces
Get-WorkspacesStatistics

while ( $(Get-WorkspacesCount) -gt $(Get-WorkspacesCountWSReady)) {
    Start-Sleep -seconds $global:LoopSleepSeconds
    Write-Host .
    while ($(Get-WorkspacesCountWIS) -lt $global:MaxParallelScans `
            -and $(Get-WorkspacesCountW2s) -gt 0 `
            -and $(Get-ScanRequestCountLastH) -lt $global:MaxScanRequestsPerH) { 
        Write-Host 'Starting next WorkspaceScan' 
        Start-NextWorkspaceScan          
        Get-WorkspacesStatistics      
    }
   IF ($(Get-StatusRequestCountLastH) -lt $global:MaxStatusRequestsPerH) {
        Get-ScanStatus
        Get-WorkspacesStatistics
   }
   while ($(get-WorkspacesCountWSR) -gt 0 -and $(Get-ResultFetchesCountLastH) -lt $global:MaxScanResultsPerH) { 
        Get-WorkspaceScanResults
   } 
} 
