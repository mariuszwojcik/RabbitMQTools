<#
.Synopsis
   Get overview information about RabbitMQ server.

.DESCRIPTION
   The Get-RabbitMQOverview gets overview information about one or more RabbitMQ servers.

   Returned object contains information about RabbitMQ server such as its version, Erlang version, node name, number of exchanges, queues, messages, consumers, connection and channels. It also contains object with server statistics.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.INPUTS
   You can pipe ComputerName to the cmdlet.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.ServerOverview objects which describe RabbitMQ server. 

.EXAMPLE
   Get-RabbitMQOverview

   Gets overview information about local RabbitMQ server.

.EXAMPLE
   Get-RabbitMQOverview localhost, 127.0.0.1

   Gets overview information about following servers: localhost and 127.0.0.1. This command can be used to compare different instances.

.EXAMPLE
   @('localhost', '127.0.0.1') | Get-RabbitMQOverview

   This example shows how to pipe list of servers for which to get overview information. In the above example the cmdlet will show information about following servers: localhost and 127.0.0.1.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQOverview
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("cn", "HostName", "ComputerName")]
        [string[]]$Name = $defaultComputerName,
        
        
        # UserName to use when logging to RabbitMq server.
        [Parameter(Mandatory=$true, ParameterSetName='login')]
        [string]$UserName,

        # Password to use when logging to RabbitMq server.
        [Parameter(Mandatory=$true, ParameterSetName='login')]
        [string]$Password,

        # Credentials to use when logging to RabbitMQ server.
        [Parameter(Mandatory=$true, ParameterSetName='cred')]
        [PSCredential]$Credentials
    )

    Begin
    {
        $Credentials = NormaliseCredentials
    }
    Process
    {
        if (-not $pscmdlet.ShouldProcess("server $ComputerName", "Get overview: $(NamesToString $Name '(all)')"))
        {
            foreach ($cn in $Name)
            {
                Write-Host "Getting overview for server: $cn"
            }
            return;
        }

        foreach ($cn in $Name)
        {
            $overview = GetItemsFromRabbitMQApi -ComputerName $cn $Credentials "overview"
            $overview | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $cn
            $overview.PSObject.TypeNames.Insert(0, "RabbitMQ.ServerOverview")

            Write-Output $overview
        }
    }
    End
    {
    }
}
