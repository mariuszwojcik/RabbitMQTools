<#
.Synopsis
   Unregisters RabbitMQ server.

.DESCRIPTION
   Unregister-RabbitMQ server cmdlet allows to remove RabbitMQ server from tab completition list for ComputerName.

.EXAMPLE
   Unregister-RabbitMQServer '127.0.0.1'

   Removes server 127.0.0.1 from auto completition list for ComputerName parameter.
#>
function Unregister-RabbitMQServer
{
    [CmdletBinding()]
    Param
    (
        # Name of the RabbitMQ server to be unregistered.
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        $ComputerName
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

        if ($obj)
        {
            $global:RabbitMQServers = $global:RabbitMQServers | ? ListItemText -ne $ComputerName
        }
    }
    End
    {
    }
}