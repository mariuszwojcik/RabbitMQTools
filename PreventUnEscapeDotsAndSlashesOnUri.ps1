function PreventUnEscapeDotsAndSlashesOnUri
{
    $protocol = "http"
    $UnEscapeDotsAndSlashes = 0x2000000

    $getSyntax = [System.UriParser].GetMethod("GetSyntax", 40)
    $flags = [System.UriParser].GetField("m_Flags", 36)

    $parser = $getSyntax.Invoke($null, $protocol)
    $currentValue = $flags.GetValue($parser)

    $a = $v -band 0x2000000 
    if (($currentValue -band $UnEscapeDotsAndSlashes) -eq $UnEscapeDotsAndSlashes) {
        Write-Verbose "UriParser is automatically un-escaping dots and slashes. Switching off the flag."

        $newValue = $currentValue -bxor $UnEscapeDotsAndSlashes
        $flags.SetValue($parser, $newValue)

        Write-Verbose "Un-escaping dots and slashes flag has been switched switched off."
    }
}


PreventUnEscapeDotsAndSlashesOnUri