

$global:formanatorCache = @{}

function Test-Formanator{
    [CmdletBinding()]
    param()

    $cmdName = "formanator"
    $serviceName = "Flexible Reimbursement Account"

    try{

        # Test formator command present
        $gcm = Get-Command $cmdName -ErrorAction SilentlyContinue
        
        if(-not $gcm){
            throw "The command 'formanator' is not found. Please make sure it is installed and available in the system PATH."
        }
        
        # Test formator call
        $response = Invoke-Formanator -Command "benefits"
        
        $fc = $response | Convert-FormaClaimResponseToObject

        if($fc.Name -eq $serviceName){
            $ret = $true
        } else {
            throw "The command 'formanator' is found but the service name does not match. Expected: '$serviceName', Found: '$($fc.Name)'"
        }
        "Test-Formanator: $ret" | Write-MyDebug -Section "formanator" -Object $fc
        
        return $ret
    }
    catch {
        $_.Exception.Message | Write-MyDebug -Section "formanator"
        return $false
    }

} Export-ModuleMember -Function Test-Formanator

function  Invoke-Formanator_List_Claims {
    [CmdletBinding()]
    param (
        [Parameter()] [switch]$Force
    )

    if(-Not $Force -and (Test-DatabaseKey "list-claims")) {
        return Get-DatabaseKey "list-claims"
    }
    
    $cmd = "list-claims"

    $response = Invoke-Formanator -Command $cmd

    # Cache
    Save-DatabaseKey -Key "list-claims" -Value $response

    return $response
}

function Invoke-Formanator_SubmitClaimFromFolder {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string]$Path
    )

    $cmd = "submit-claims-from-directory --directory $Path --dry-run"

    Invoke-Formanator -Command $cmd -Interactive
}

function Invoke-Formanator {
    [CmdletBinding()]
    param (
        [Parameter()] [string]$Command,
        [Parameter()] [switch]$Interactive
    )

    $command = "$Command"
    $expression = "formanator $command"
    
    "Invoke >>> : $command" | Write-MyDebug -Section "formanator"

    if($Interactive){
        "Interactive mode enabled. The formanator command will be run in interactive mode." | Write-MyDebug -Section "formanator"
        Invoke-Expression -Command $expression

    } else {

        $expression = $expression + " *>&1"
    
        $response = Invoke-Expression -Command $expression
    
        # Check if $response is [System.Management.Automation.ErrorRecord] or an array of [System.Management.Automation.ErrorRecord]
        if($response[0] -is [System.Management.Automation.ErrorRecord]){
            $errorMsg = $response.Exception.Message -join "`n"
            throw "Error invoking formanator: $errorMsg"
        }
    }

    "Invoke <<< : $command" | Write-MyDebug -Section "formanator"

    return $response
}