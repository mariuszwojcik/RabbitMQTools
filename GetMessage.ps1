<#
.Synopsis
   Gets messages from RabbitMQ Queue.

.DESCRIPTION
   The Get-RabbitMQMessage cmdlet gets messages from RabbitMQ queue.

   The result may be zero, one or many RabbitMQ.Message objects.

   To get Connections from remote server you need to provide -ComputerName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

.EXAMPLE
   Get-RabbitMQMessage vh1 q1

   This command gets first message from queue "q1" on virtual host "vh1".

.EXAMPLE
   Get-RabbitMQMessage test q1 -Count 10

   This command gets first 10 messages from queue "q1" on virtual host "vh1".

.EXAMPLE
   Get-RabbitMQMessage test q1 127.0.0.1

   This command gets first message from queue "q1" on virtual host "vh1", server 127.0.0.1.

.INPUTS

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueMessage objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Get-RabbitMQMessage
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of the virtual host to filter channels by.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost = $defaultVirtualhost,

        # Name of RabbitMQ Queue.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("queue", "QueueName")]
        [string]$Name = "",

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("HostName", "hn", "cn")]
        [string]$ComputerName = $defaultComputerName,
        
        # UserName to use when logging to RabbitMq server. Default value is guest.
        [string]$UserName = $defaultUserName,

        # Password to use when logging to RabbitMq server. Default value is guest.
        [string]$Password = $defaultPassword,

        # Number of messages to get. Default value is 1.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$Count = 1,

        # Indicates whether messages should be removed from the queue. Default setting is to not remove messages.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [switch]$Remove,

        # Determines message body encoding.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [ValidateSet("auto", "base64")]
        [string]$Encoding = "auto",

        # Indicates whether messages body should be truncated to given size (in bytes).
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [int]$Truncate
    )

    Begin
    {
        Add-Type -AssemblyName System.Web
        Add-Type -AssemblyName System.Net
         
        $cred = GetRabbitMqCredentials $UserName $Password
        $cnt = 0
    }
    Process
    {
        [string]$s
        if ([bool]$Remove) { $s = "Messages will be removed from the queue." } else {$s = "Messages will be requeued."}
        if ($pscmdlet.ShouldProcess("server: $ComputerName/$VirtualHost", "Get $Count message(s) from queue $Name. $s"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/queues/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($Name))/get"
            Write-Verbose "Invoking REST API: $url"

            $body = @{
                "count" = $Count
                "requeue" = -not [bool]$Remove
                "encoding" = $Encoding
            }
            if ($Truncate) { $body.Add("truncate", $Truncate) }

            $bodyJson = $body | ConvertTo-Json

            Write-Debug "body: $bodyJson"

            $result = Invoke-RestMethod $url -Credential $cred -AllowEscapedDotsAndSlashes -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson

            #$result | Add-Member -NotePropertyName "no" -NotePropertyValue $cnt++
            $result | Add-Member -NotePropertyName "QueueName" -NotePropertyValue $Name

            foreach ($item in $result)
            {
                $cnt++
                $item | Add-Member -NotePropertyName "no" -NotePropertyValue $cnt
            }

            SendItemsToOutput $result "RabbitMQ.QueueMessage"

        }
    }
    End
    {
        Write-Verbose "`r`nGot $cnt messages from queue $Name, vhost $VirtualHost, server: $ComputerName."
    }
}
