function Get-FormaClaimCategories {
    [CmdletBinding()]
    param (
        [Parameter()] [switch]$Force
    )

    try{

        $benefits = Get-FormaClaimBenefits -Force:$Force

        $response = Invoke-Formanator_Categories -BenefitName $benefits.Name -Force:$Force

        $fc = $response | Convert-FormaClaimResponseToObject

        return $fc
    }
    catch {
         $_.Exception.Message | write-MyError
    }

} Export-ModuleMember -Function Get-FormaClaimCategories

function getCategoryParameterList{
    param($commandName, $parameterName, $wordToComplete, $commandAst)
    
    $cat = Get-FormaClaimCategories

    $catList = $cat.Category

    $ret = $catList | ConvertTo-CompleteResults -wordToComplete $wordToComplete

    return $ret
}

function Invoke-Formanator_Categories {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string]$BenefitName,
        [Parameter()] [switch]$Force
    )

    $key = "categories"

    if(-Not $Force -and (Test-DatabaseKey $key)) {
        "✅ Return [$key] from cache" | Write-MyDebug -Section "formanator"
        return Get-DatabaseKey $key
    }
    
    $cmd = "categories --benefit '$BenefitName'"

    $response = Invoke-Formanator -Command $cmd

    # Cache
    Save-DatabaseKey -Key $key -Value $response

    return $response

} Export-ModuleMember -Function Get-FormaClaimCategories