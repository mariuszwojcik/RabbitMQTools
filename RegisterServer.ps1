<#
.Synopsis
   Registers RabbitMQ server.

.DESCRIPTION
   Register-RabbitMQ server cmdlet allows to add RabbitMQ server to the tab completition list for ComputerName.

.EXAMPLE
   Register-RabbitMQServer '127.0.0.1'

   Adds server 127.0.0.1 to auto completition list for ComputerName parameter.

.EXAMPLE
   Register-RabbitMQServer '127.0.0.1' 'My local PC'

   Adds server 127.0.0.1 to auto completition list for ComputerName parameter. The text 'My local PC' will be used as a tooltip.
#>
function Register-RabbitMQServer
{
    [CmdletBinding()]
    Param
    (
        # Name of the RabbitMQ server to be registered.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        $ComputerName,

        # Description to be used in tooltip. If not provided then computer name will be used.
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=1)]
        $Description
    )

    Begin
    {
        if (-not $global:RabbitMQServers)
        { 
            $global:RabbitMQServers = @() 
        }
    }
    Process
    {
        $obj += $global:RabbitMQServers | ? ListItemText -eq $ComputerName
        if (-not $obj)
        {
            if (-not $Description) { $Description = $ComputerName }
            $escapedComputerName = $ComputerName -replace '\[', '``[' -replace '\]', '``]'
            $global:RabbitMQServers += New-Object System.Management.Automation.CompletionResult $escapedComputerName, $ComputerName, 'ParameterValue', $Description
        } else {
            Write-Warning "Server $ComputerName is already registered. If you want to update the entry you need to unregister the server and register it again"
        }
    }
    End
    {
    }
}