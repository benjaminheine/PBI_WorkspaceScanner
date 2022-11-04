# DAtum: 20221104 Author: B. Heine, J. Heine

class Workspace_Scan {
    [string]$WS_ID
    [System.DateTime]$ScanStartDate
    [System.DateTime]$ScanReadyDate
    [System.DateTime]$ScanResultRequestStartDate
    [System.DateTime]$ScanResultRequestEndDate
    [string]$Status
    [string]$ScanRequestId
}

$global:WorspaceScans = @()

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
    Write-Host '# Workspaces array :' $global:WorspaceScans.Count
    Write-Host '# W2S              :' $(Get-WorkspacesCountW2S)
    Write-Host '# WIS              :' $(Get-WorkspacesCountWIS)
    Write-Host '# WSR              :' $(Get-WorkspacesCountWSR)
    Write-Host '# WRE              :' $(Get-WorkspacesCountWRE)
    Write-Host '# WSReady          :' $(Get-WorkspacesCountWSReady)




}



#Main
Get-ModifiedWorkspaces
Get-WorkspacesStatistics
#$WorspaceScans.Count