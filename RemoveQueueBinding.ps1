<#
.Synopsis
   Removes binding between RabbitMQ Queue and Exchange.

.DESCRIPTION
   The Remove-RabbitMQQueueBinding allows for removing bindings between RabbitMQ queues and exchanges. This cmdlet is marked with High impact.

   To remove Queue binding from remote server you need to provide -ComputerName.

   You may pipe an object with names and, optionally, with computer names to remove multiple Queues. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Remove-RabbitMQQueueBinding vh1 e1 q1 'e1-q1'

   This command removes binding "e1-q1" between exchange named "e1" and queue named "q1". The operation is performed on local server in virtual host vh1.

.EXAMPLE
   Remove-RabbitMQQueueBinding vh1 e1 q1 'e1-q1' 127.0.0.1

   This command removes binding "e1-q1" between exchange named "e1" and queue named "q1". The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE
   Remove-RabbitMQQueueBinding -ComputerName 127.0.0.0 -VirtualHost vh1 -ExchangeName e1 -QueueName q1 -RoutingKey 'e1-q1'

   This command removes binding "e1-q1" between exchange named "e1" and queue named "q1". The operation is performed on server 127.0.0.1 in default virtual host (/).

.EXAMPLE

.INPUTS

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQQueueBinding
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param
    (
        # Name of RabbitMQ Virtual Host.
        [parameter(Mandatory = $true, ValueFromPipelineByPropertyName=$true, Position = 0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost = $defaultVirtualhost,

        # Name of RabbitMQ Exchange.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("exchange")]
        [string]$ExchangeName,

        # Name of RabbitMQ Queue.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("queue", "QueueName")]
        [string]$Name,

        # Routing key.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=3)]
        [Alias("rk")]
        [string]$RoutingKey,

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=4)]
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
        $cnt = 0

    }
    Process
    {
        if ($pscmdlet.ShouldProcess("$ComputerName/$VirtualHost", "Remove binding between exchange $ExchangeName and queue $Name"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/bindings/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/e/$([System.Web.HttpUtility]::UrlEncode($ExchangeName))/q/$([System.Web.HttpUtility]::UrlEncode($Name))/$([System.Web.HttpUtility]::UrlEncode($RoutingKey))"
            Write-Verbose "Invoking REST API: $url"
        
            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Delete

            Write-Verbose "Removed binding between exchange $ExchangeName and queue $Name $n on $ComputerName/$VirtualHost"
            $cnt++
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Unbound $cnt Queues." }
    }
}
