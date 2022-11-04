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

$Workspace_Scan1 = [Workspace_Scan]::new()
$Workspace_Scan1.Status = 'W2S'

$student1 = [student]::new()
$student1.FirstName = 'Tyler'
$student1.LastName = 'Muir'
$student1