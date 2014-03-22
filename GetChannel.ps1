<#
.Synopsis
   Gets open RabbitMQ Channels.

.DESCRIPTION
   The Get-RabbitMQChannel cmdlet gets list of opened channels.

   The cmdlet allows you to show list of opened channels or filter them by name using wildcards.
   The result may be zero, one or many RabbitMQ.Channel objects.

   To get Nodes from remote server you need to provide -ComputerName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQChannel

   This command gets a list of opened channels.

.EXAMPLE
   Get-RabbitMQChannel -ComputerName myrabbitmq.servers.com

   This command gets a list of opened channels to myrabbitmq.servers.com server.

.EXAMPLE
   Get-RabbitMQChannel *53232*

   This command gets a list of all opened channels which name has "53232" number in it.

.EXAMPLE
   Get-RabbitMQChannel -VirtualHost vhost1

   This command gets all opened channels which are using Virtual Host named "vhost1".


.EXAMPLE
   @("*53232*", "*53234*") | Get-RabbitMQChannel

   This command pipes channel name filters to Get-RabbitMQChannel cmdlet.

.INPUTS
   You can pipe channel Name to filter the results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.Channel objects which describe cluster nodes.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQChannel
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of RabbitMQ Node.
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias("Channel", "ChannelName")]
        [string[]]$Name = "",
               
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("HostName", "hn", "cn")]
        [string]$ComputerName = $defaultComputerName,

        # Name of the virtual host to filter channels by.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost,
        
        
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
        if ($pscmdlet.ShouldProcess("server $ComputerName", "Get node(s): $(NamesToString $Name '(all)')"))
        {
            $result = GetItemsFromRabbitMQApi -ComputerName $ComputerName $Credentials "channels"
            
            $result = ApplyFilter $result 'name' $Name
            if ($VirtualHost) { $result = ApplyFilter $result 'vhost' $VirtualHost }

            $result | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $ComputerName

            SendItemsToOutput $result "RabbitMQ.Channel"
        }
    }
    End
    {
    }
}
