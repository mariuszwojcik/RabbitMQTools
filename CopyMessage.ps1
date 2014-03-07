<#
.Synopsis
   Copies messages from one RabbitMQ Queue to another.

.DESCRIPTION
   The Copy-RabbitMQMessage cmdlet allows to copy messages from one RabbitMQ queue to another.
   Both source and destination queues must be in the same Virtual Host.
   The "exchange" and "routing_key" properties on copied messages will ba changed.

   Copying messages is done by creating new exchange, binding both from and to queues to it and republishing messages from source queue. 
   
   The cmdlet is not designed to be used on sensitive data.

   WARNING
     This operation is not transactional and may result in not all messages being copied or some messages being duplicated. 
     Also, if there are new messages published to the source queue or messages are consumed, then the operation may fail with unexpected result.
     Because of the nature of copying messages, this operation may change order of messages in the source queue.
     

   To copy messages on remote server you need to provide -ComputerName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Copy-RabbitMQMessage vh1 q1 q2

   Copy all messages from q1 to q2 on Virtual Host vh1.

.EXAMPLE
   Copy-RabbitMQMessage vh1 q1 q2 5

   Copy first 5 messages from q1 to q2 on Virtual Host vh1.

.EXAMPLE
   Copy-RabbitMQMessage -VirtualHost vh1 -$SourceQueueName q1 -$DestinationQueueName q2 -Count 5

   Copy first 5 messages from q1 to q2 on Virtual Host vh1.

.INPUTS

.OUTPUTS
   By default, the cmdlet returns list of RabbitMQ.QueueMessage objects which describe connections. 

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Copy-RabbitMQMessage
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact='High')]
    Param
    (
        # Name of the virtual host to filter channels by.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost,

        # Name of RabbitMQ Queue from which messages should be copied.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [Alias("from", "fromQueue")]
        [string]$SourceQueueName,

        # Name of RabbitMQ Queue to which messages should be copied.
        [parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [Alias("to", "toQueue")]
        [string]$DestinationQueueName,

        # If specified, gives the number of messages to copy.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=3)]
        [int]$Count,

        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true, Position=4)]
        [Alias("HostName", "hn", "cn")]
        [string]$ComputerName = $defaultComputerName,
        
        # UserName to use when logging to RabbitMq server. Default value is guest.
        [string]$UserName = $defaultUserName,

        # Password to use when logging to RabbitMq server. Default value is guest.
        [string]$Password = $defaultPassword
    )

    Begin
    {
        Add-Type -AssemblyName System.Web
        Add-Type -AssemblyName System.Net
         
        $cred = GetRabbitMqCredentials $UserName $Password
        $cnt = 0
        $requiresMessageRemoval = $SourceQueueName -ne $DestinationQueueName
    }
    Process
    {
        $s = @{$true=$Count;$false='all'}[$Count -gt 0]
        if ($pscmdlet.ShouldProcess("server: $ComputerName/$VirtualHost", "Copy $s messages from queue $SourceQueueName to queue $DestinationQueueName."))
        {
            $ename = "RabbitMQTools_copy"
            $routingKey = "RabbitMQTools_copy"
            Add-RabbitMQExchange -VirtualHost $vhost -Type fanout -AutoDelete -Name $ename
            Add-RabbitMQQueueBinding -VirtualHost $vhost -ExchangeName $ename -Name $srcq  -RoutingKey $routingKey
            Add-RabbitMQQueueBinding -VirtualHost $vhost -ExchangeName $ename -Name $destq -RoutingKey $routingKey

            try
            {
                $m = Get-RabbitMQMessage $VirtualHost $SourceQueueName
                $c = $m.message_count + 1

                if ($Count -eq 0 -or $Count -gt $c ) { $Count = $c }
                Write-Verbose "There are $Count messages to be copied."

                for ($i = 1; $i -le $Count; $i++)
                {
                    # get message to be copies, but do not remove it from the server yet.
                    $m = Get-RabbitMQMessage $VirtualHost $SourceQueueName

                    # publish message to copying exchange, this will publish it onto dest queue as well as src queue.
                    Add-RabbitMQMessage $vhost $ename $routingKey $m.payload $m.properties

                    # remove message from src queue. It has been published step earlier.
                    if ($requiresMessageRemoval) { $m = Get-RabbitMQMessage $VirtualHost $SourceQueueName -Remove }

                    Write-Verbose "published message $i out of $Count"
                    $cnt++
                }
            }
            finally
            {
                Remove-RabbitMQExchange -VirtualHost $vhost -Name $ename -Confirm:$false
            }
        }
    }
    End
    {
        Write-Verbose "`r`nCopied $cnt messages from queue $SourceQueueName to queue $DestinationQueueName."
    }
}
