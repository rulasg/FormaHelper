
function Get-FormaClaimFields{
    [cmdletBinding()]
    param()

    $response = Invoke-Formanator_List_Claims

    $fields = splitRecordLine -Line $response[1]

    return $fields
} Export-ModuleMember -Function Get-FormaClaimFields