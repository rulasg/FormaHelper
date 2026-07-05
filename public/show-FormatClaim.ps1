
function Show-FormaClaim {
    param (
        [Parameter()] [switch]$Force,
        [Parameter()] [switch]$PassThru,
        [Parameter()] [switch]$All,
        [Parameter()] [string[]]$Attributes

    )

    $list = Get-FormaClaim -Force:$Force

    # TODO: Filter claims of this period. Check date proceesed
    # Ad null and this year
    if(-not $All){
        $list = $list | Where-Object { $_.isActive }
    }

    # Sort
    $ret = $list | Sort-Object -Property "Date Processed"

    # Return values
    if($PassThru){
        return $ret
    } else {
        # Show Format TTable
        if ($Attributes) {
            $ret | Format-Table $Attributes
        } else {
            $ret | Format-Table "Date Processed","Reimbursement Vendor","Status","Amount"
        }
    }

} Export-ModuleMember -Function Show-FormaClaim