<#
.Synopsis
   Gets Virtual Hosts registered with the server.

.DESCRIPTION
   The Get-RabbitMQVirtualHost gets Virtual Hosts registered with RabbitMQ server.

   The cmdlet allows you to show all Virtual Hosts or filter them by name using wildcards.
   The result may be zero, one or many RabbitMQ.VirtualHost objects.

   To get Virtual Hosts from remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQVirtualHost

   This command gets a list of all Virtual Hosts registered with RabbitMQ on local server.

.EXAMPLE
   Get-RabbitMQVirtualHost -ComputerName myrabbitmq.servers.com

   This command gets a list of all Virtual Hosts registered with RabbitMQ on myrabbitmq.servers.com server.

.EXAMPLE
   Get-RabbitMQVirtualHost private*

   This command gets a list of all Virtual Hosts which name starts with "private".

.EXAMPLE
   Get-RabbitMQVirtualHost private*, public*

   This command gets a list of all Virtual Hosts which name starts with "private" or "public".

.EXAMPLE
   Get-RabbitMQVirtualHost private*, public*

   This command gets a list of all Virtual Hosts which name starts with "private" or "public".

.EXAMPLE 
    Get-RabbitMQVirtualHost marketing_private | select *

    This command selects all properties for given Virtual Host.

.EXAMPLE
   @("private*", "*public") | Get-RabbitMQVirtualHost

   This command pipes name filters to Get-RabbitMQVirtualHost cmdlet.

.INPUTS
   You can pipe Virtual Host names to filter results.

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.VirtualHost objects which describe Virtual Hosts. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQVirtualHost
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact='None')]
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
        if ($pscmdlet.ShouldProcess("server $ComputerName", "Get vhost(s): $(NamesToString $Name '(all)')"))
        {
            $vhosts = GetItemsFromRabbitMQApi -ComputerName $ComputerName $Credentials "vhosts"
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
