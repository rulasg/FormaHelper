function Get-FormaClaim {
    param (
        [Parameter()] [switch]$Force
    )

    try{

        $response = Invoke-Formanator_List_Claims -Force:$Force
        
        $fc = $response | Convert-FormaClaimResponseToObject -AsHashtable
        
        $ret = $fc | ForEach-Object { [PSCustomObject] (Expand-FormaClaimObject -Claim $_) }
        
        $ret = $ret | sortFormClaims 
        
        return $ret
    }
    catch {
         $_.Exception.Message | write-MyError
    }

} Export-ModuleMember -Function Get-FormaClaim

function sortFormClaims{
    [CmdletBinding()]
    [outputType([array])]
    param(
        [Parameter(Position=0,ValueFromPipeline)][array]$list
    )

    begin { $allItems = @() }
    process { $allItems += $list }
    end {
        $properties = @(
            @{ Expression = "Date"                 ; Descending = $true  }
            @{ Expression = "Status"               ; Descending = $false }
            @{ Expression = "Reimbursement Vendor" ; Descending = $false }
            @{ Expression = "Amount"               ; Descending = $true  }
        )
        $ret = $allItems | Sort-Object $properties

        return $ret
    }
}

function Convert-FormaClaimResponseToObject{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [string[]]$Response,
        [Parameter()] [switch]$AsHashtable
    )

    begin {
        $responseAll = @()
    }

    process {
        $responseAll += $Response
    }

    end {
        $ret = @()
        
        $lastRecord = $responseAll.Length -2

        $fields = splitRecordLine -Line $responseAll[1]
        
        foreach ($i in 3..$lastRecord) {

            $record = splitRecordLine -Line $responseAll[$i]

            if ([string]::IsNullOrWhiteSpace($record[0])) {
                continue
            }

            # Ad the known fields to the object
            $obj = @{}
            0..($fields.Length - 1) | ForEach-Object {
                $obj[$fields[$_]] = $record[$_]
            }

            # save object to list
            $ret += $AsHashtable ? $obj : [PSCustomObject]$obj
        }
        return $ret
    }
    
} Export-ModuleMember -Function Convert-FormaClaimResponseToObject

function splitRecordLine{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)] [string[]]$Line
    )

    $splitchar = "│"

    $fields = $Line.Split($splitchar).Trim()
    $fields = $fields[1..($fields.Length - 2)]

    return $fields
}

function Expand-FormaClaimObject{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory,ValueFromPipeline)] [object]$Claim
    )

    process{

        # Convert amount from string to decimal
        $amountString = $Claim."Amount"
        $usCulture = [System.Globalization.CultureInfo]::new('en-US')
        $Claim.Amount = [string]::IsNullOrWhiteSpace($amountString) ? 0 : [decimal]::Parse($amountString, [System.Globalization.NumberStyles]::Currency, $usCulture)
        
        # Add extra fields to the object
        $dateString = $Claim."Date Processed"
        $Claim.Date = [string]::IsNullOrWhiteSpace($dateString) ? [datetime]::MaxValue : [datetime]::Parse($dateString)
        $Claim.isActive = $Claim.Date.Year -ge (Get-Date).Year
        
        return $Claim
    }
}