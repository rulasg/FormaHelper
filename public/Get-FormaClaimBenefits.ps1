function Get-FormaClaimBenefits {
    [CmdletBinding()]
    param (
        [Parameter()] [switch]$Force
    )

    try{
        $response =  Invoke-Formanator_Benefits -Force:$Force

        $fc = $response | Convert-FormaClaimResponseToObject

        return $fc
    } catch {
         $_.Exception.Message | write-MyError
    }
} Export-ModuleMember -Function Get-FormaClaimBenefits

function Invoke-Formanator_Benefits {
    [CmdletBinding()]
    param (
        [Parameter()] [switch]$Force
    )

    $key = "benefits"

    if(-Not $Force -and (Test-DatabaseKey $key)) {
        "✅ Return [$key] from cache" | Write-MyDebug -Section "formanator"
        return Get-DatabaseKey $key
    }
    
    $cmd = "benefits"

    $response = Invoke-Formanator -Command $cmd

    # Cache
    Save-DatabaseKey -Key $key -Value $response

    return $response

} Export-ModuleMember -Function Get-FormaClaimBenefits