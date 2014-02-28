function Get-RabbitMQVirtualHost
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of RabbitMQ Virtual Host.
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position = 0)]
        [Alias("vh", "VirtualHost")]
        [string[]]$Name = "",

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("HostName", "hn", "cn")]
        [string]$ComputerName = $defaultComputerName,
        
        # UserName to use when logging to RabbitMq server. Default value is guest.
        [string]$UserName = $defaultUserName,

        # Password to use when logging to RabbitMq server. Default value is guest.
        [string]$Password = $defaultPassword
    )

    Begin
    {
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("server $ComputerName", "Get vhost(s): $(NamesToString $Name '(all)')"))
        {
            $vhosts = GetItemsFromRabbitMQApi $ComputerName $UserName $Password "vhosts"
            $result = ApplyFilter $vhosts "name" $Name

            foreach($i in $result)
            {
                $i | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $ComputerName
            }

            SendItemsToOutput $result "RabbitMQ.VirtualHost"
        }
    }
    End
    {
    }
}
