function ApplyFilter
{
    Param (
        [parameter()]
        [PSObject[]]$items,
        
        [parameter(Mandatory=$true)]
        [string]$prop,
        
        [string[]]$name
    )

    if (-not $name) { return $items }
            
    # apply property filter
    $filter = @()
    foreach($n in $name) { $filter += '$_.' + $prop + '-like "' + $n + '"' }

    $sb = [scriptblock]::create($filter -join ' -or ')
    return $items | ? $sb
}
