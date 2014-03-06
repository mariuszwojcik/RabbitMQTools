if (Test-Path Function:TabExpansion2) {
    $OldTabExpansion = Get-Content Function:TabExpansion2
}

$Module = $MyInvocation.MyCommand.ScriptBlock.Module 
$Module.OnRemove = {

    #$Function:TabExpansion2 = $OldTabExpansion

    #Remove-Variable -name UnEscapeDotsAndSlashes -Force
    #Remove-Variable -name defaultUriParserFlagsValue -Force
    #Remove-Variable -name uriUnEscapesDotsAndSlashes -Force
}


# Aliases
New-Alias -Name grvh -value Get-RabbitMQVirtualHost -Description "Gets RabbitMQ's Virutal Hosts"

# Modules
Export-ModuleMember -Function Get-RabbitMQVirtualHost, Add-RabbitMQVirtualHost, Remove-RabbitMQVirtualHost
Export-ModuleMember -Function Get-RabbitMQOverview
Export-ModuleMember -Function Get-RabbitMQExchange, Add-RabbitMQExchange, Remove-RabbitMQExchange

Export-ModuleMember -Function Get-RabbitMQConnection, RemoveConnection.ps1
Export-ModuleMember -Function Get-RabbitMQNode
