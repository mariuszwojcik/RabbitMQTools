<#
.Synopsis
   Purges all messages from RabbitMQ Queue.

.DESCRIPTION
    The Clear-RabbitMQQueue removes all messages from given RabbitMQ queue.

   To remove message from Queue on remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Clear-RabbitMQQueue vh1 q1

   Removes all messages from queue "q1" in Virtual Host "vh1" on local computer.

.EXAMPLE
   Clear-RabbitMQQueue -VirtualHost vh1 -Name q1

   Removes all messages from queue "q1" in Virtual Host "vh1" on local computer.

.EXAMPLE
   Clear-RabbitMQQueue -VirtualHost vh1 -Name q1 -ComputerName rabbitmq.server.com

   Removes all messages from queue "q1" in Virtual Host "vh1" on "rabbitmq.server.com" server.
#>
function Clear-RabbitMQQueue
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param
    (
        # Name of RabbitMQ Virtual Host.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost = $defaultVirtualHost,

        # The name of the queue from which to receive messages
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("qn", "QueueName")]
        [string]$Name,
        
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("cn", "HostName")]
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
        if ($pscmdlet.ShouldProcess("server: $ComputerName/$VirtualHost", "purge queue $Name"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/queues/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($Name))/contents"
            Write-Verbose "Invoking REST API: $url"

            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Delete
        }
    }
    End
    {
    }
}
