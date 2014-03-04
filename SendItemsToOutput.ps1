function SendItemsToOutput
{
    Param
    (
        [parameter()]
        [PSObject[]]$items,

        [parameter(Mandatory=$true)]
        [string[]]$typeName
    )

    foreach ($i in $items)
    {
        $i.PSObject.TypeNames.Insert(0, $typeName)
        Write-Output $i
    }
}