<#
.Synopsis
   Gets messages from RabbitMQ Queue.

.DESCRIPTION
   The Add-RabbitMQMessage cmdlet gets messages from RabbitMQ queue.

   The result may be zero, one or many RabbitMQ.Message objects.

   To get Connections from remote server you need to provide -ComputerName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Add-RabbitMQMessage vh1 q1

   This command gets first message from queue "q1" on virtual host "vh1".

.EXAMPLE
   Add-RabbitMQMessage test q1 -Count 10

   This command gets first 10 messages from queue "q1" on virtual host "vh1".

.EXAMPLE
   Add-RabbitMQMessage test q1 127.0.0.1

   This command gets first message from queue "q1" on virtual host "vh1", server 127.0.0.1.

.INPUTS

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueMessage objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQMessage
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of the virtual host to filter channels by.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost,

        # Name of RabbitMQ Exchange.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("exchange")]
        [string]$ExchangeName,

        # Routing key to be used when publishing message.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("rk")]
        [string]$RoutingKey,
        
        # Massage's payload
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=3)]
        [string]$Payload,

        # Array with message properties.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=4)]
        $Properties,

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

        if ($Properties -eq $null) { $Properties = @{} }
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("server: $ComputerName/$VirtualHost", "Publish message to exchange $ExchangeName with routing key $RoutingKey"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/exchanges/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($ExchangeName))/publish"
            Write-Verbose "Invoking REST API: $url"

            $body = @{
                routing_key = $RoutingKey
                payload_encoding = "string"
                payload = $Payload
                properties = $Properties
            }

            $bodyJson = $body | ConvertTo-Json

            
            $retryCounter = 0

            while ($retryCounter -lt 3)
            {
                $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson

                if ($result.routed -ne $true)
                {
                    Write-Warning "Message was no routed. Operation will be retried. URI: $url"
                    $retryCounter++
                }
                else
                {
                    break
                }
            }
        }
    }
    End
    {
    }
}
