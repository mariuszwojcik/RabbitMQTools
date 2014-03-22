<#
.Synopsis
   Adds Exchange to RabbitMQ server.

.DESCRIPTION
   The Add-RabbitMQExchange allows for creating new Exchanges in given RabbitMQ server.

   To add Exchange to remote server you need to provide -ComputerName.

   You may pipe an object with names and parameters, including ComputerName, to create multiple Exchanges. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQExchange -Type direct TestExchange

   Creates direct exchange named TestExchange in the local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQExchange -Type direct TestExchange -Durable -AutoDelete -Internal -AlternateExchange e2

   Creates direct exchange named TestExchange in the local RabbitMQ server and sets its properties to be Durable, AutoDelete, Internal and to use alternate exchange called e2.

.EXAMPLE
   Add-RabbitMQExchange -Type fanout TestExchange, ProdExchange

      Creates in the local RabbitMQ server two fanout exchanges named TestExchange and ProdExchange.

.EXAMPLE
   Add-RabbitMQExchange -Type direct TestExchange -ComputerName myrabbitmq.servers.com

   Creates direct exchange named TestExchange in the myrabbitmq.servers.com server.

.EXAMPLE
   @("e1", "e2") | Add-RabbitMQExchange -Type direct

   This command pipes list of exchanges to add to the RabbitMQ server. In the above example two new Exchanges named "e1" and "e2" will be created in local RabbitMQ server.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"ComputerName" = "localhost"; "Name" = "e1", "Type"="direct"}
        New-Object -TypeName psobject -Prop @{"ComputerName" = "localhost"; "Name" = "e2", "Type"="fanout"}
        New-Object -TypeName psobject -Prop @{"ComputerName" = "127.0.0.1"; "Name" = "e3", "Type"="topic", Durable=$true, $Internal=$true}
    )

   $a | Add-RabbitMQExchange

   Above example shows how to pipe parameters for creating new exchanges.
   
   In the above example three new exchanges will be created with different parameters.

.INPUTS
   You can pipe Name, Type, Durable, AutoDelete, Internal, AlternateExchange, VirtualHost and ComputerName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQExchange
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param
    (
        # Name of RabbitMQ Exchange.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("Exchange", "ExchangeName")]
        [string[]]$Name,

        # Type of the Exchange to create.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("topic", "fanout", "direct", "headers")]
        [string]$Type,

        # Determines whether the exchange should be Durable.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [switch]$Durable,
        
        # Determines whether the exchange will be deleted once all queues have finished using it.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [switch]$AutoDelete,
        
        # Determines whether the exchange should be Internal.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [switch]$Internal,

        # Allows to set alternate exchange to which all messages which cannot be routed will be send.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("alt")]
        [string]$AlternateExchange,

        # Name of RabbitMQ Virtual Host.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost = $defaultVirtualhost,

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
        if ($pscmdlet.ShouldProcess("server: $ComputerName, vhost: $VirtualHost", "Add exchange(s): $(NamesToString $Name '(all)')")) {
            
            $body = @{
                type = "$Type"
            }

            if ($Durable) { $body.Add("durable", $true) }
            if ($AutoDelete) { $body.Add("auto_delete", $true) }
            if ($Internal) { $body.Add("internal", $true) }
            if ($AlternateExchange) { $body.Add("arguments", @{ "alternate-exchange"=$AlternateExchange }) }

            $bodyJson = $body | ConvertTo-Json

            foreach($n in $Name)
            {
                $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/exchanges/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($n))"
                Write-Verbose "Invoking REST API: $url"
        
                $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -Body $bodyJson

                Write-Verbose "Created Exchange $n on server $ComputerName, Virtual Host $VirtualHost"
                $cnt++
            }
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Created $cnt Exchange(s)." }
    }
}
