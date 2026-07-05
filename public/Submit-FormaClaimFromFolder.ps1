function Submit-FormaClaimFromFolder {
    [CmdletBinding()]
    [Alias("sfc")]
    param (
        [Parameter()] [string]$Path
    )

    try{

        # read config it the path is not specified
        if([string]::IsNullOrWhiteSpace($Path)) {
            $config =  Get-FormaHelperConfig  
            $Path = $config.submitPath
        }
        
        if(-Not (Test-Path $Path)) {
            throw "The specified path '$Path' does not exist."
        }
        
        "Submiting claims from folder: $Path" | Write-MyDebug -Section "SubmitFormaClaim"
        
        Invoke-Formanator_SubmitClaimFromFolder -Path $Path
    }
    catch {
        $_.Exception.Message | Write-MyError
    }

} Export-ModuleMember -Function Submit-FormaClaimFromFolder -Alias "sfc"

Register-ArgumentCompleter -CommandName Submit-FormaClaim -ParameterName category -ScriptBlock { param($commandName, $parameterName, $wordToComplete, $commandAst) getCategoryParameterList @PsBoundParameters }
function Submit-FormaClaim{
    param(
        # path
        [Parameter(Mandatory)][string]$path,
        [Parameter(Mandatory)][string]$category,
        [Parameter(Mandatory)][string]$amount,
        [Parameter(Mandatory)][string]$merchant,
        [Parameter(Mandatory)][string]$purchaseDate,
        [Parameter(Mandatory)][string]$description
        )
        
        $benefit = "Flexible Reimbursement Account"

        $cmd = '--benefit "{benefit}" --category "{category}" --amount "{amount}" --merchant "{merchant}" --purchase-date "{purchaseDate}" --description "{description}" --receipt-path "{path}"'
        $cmd = $cmd -replace "{benefit}", $benefit
        $cmd = $cmd -replace "{category}", $category
        $cmd = $cmd -replace "{amount}", $amount
        $cmd = $cmd -replace "{merchant}", $merchant
        $cmd = $cmd -replace "{purchaseDate}", $purchaseDate
        $cmd = $cmd -replace "{description}", $description
        $cmd = $cmd -replace "{path}", $path

        $result = Invoke-formanator -Command "submit-claim $cmd" -Interactive

        return $result

} Export-ModuleMember -Function Submit-FormaClaim

Register-ArgumentCompleter -CommandName Get-FormaClaimSubmitParams -ParameterName category -ScriptBlock {getCategoryParameterList}
function Get-FormaClaimSubmitParams{
    param(
        # path
        [Parameter()][string]$path,
        [Parameter()][string]$category,
        [Parameter()][string]$amount,
        [Parameter()][string]$merchant,
        [Parameter()][string]$purchaseDate,
        [Parameter()][string]$description
        )
        $param = @{
            path = $path
            category = $category
            amount = $amount
            merchant = $merchant
            purchaseDate = $purchaseDate
            description = $description
        }
        
        return $param
    } Export-ModuleMember -Function Get-FormaClaimSubmitParams
