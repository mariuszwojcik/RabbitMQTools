function NamesToString
{
    Param
    (
        [string[]]$name,
        [string]$altText = ""
    )

    if (-not $name) { return $altText }

    return $name -join ';'
}