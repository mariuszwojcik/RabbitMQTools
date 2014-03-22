<#
.Synopsis
   Moves messages from one RabbitMQ Queue to another.

.DESCRIPTION
   The Move-RabbitMQMessage cmdlet allows to move messages from one RabbitMQ queue to another.
   Both source and destination queues must be in the same Virtual Host.
   The "exchange" and "routing_key" properties on moved messages will ba changed.

   Moving messages is done by publishing source message on the destination queue and removing it from source queue. 
   
   The cmdlet is not designed to be used on sensitive data.

   WARNING
     This operation is not transactional and may result in not all messages being moved or some messages being duplicated. 
     Also, if there are new messages published to the source queue or messages are consumed, then the operation may fail with unexpected result.
     Because of the nature of moving messages, this operation may change order of messages in the destination queue.
     

   To move messages on remote server you need to provide -ComputerName parameter.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Move-RabbitMQMessage vh1 q1 q2

   Moves all messages from q1 to q2 on Virtual Host vh1.

.EXAMPLE
   Move-RabbitMQMessage vh1 q1 q2 5

   Moves first 5 messages from q1 to q2 on Virtual Host vh1.

.EXAMPLE
   Move-RabbitMQMessage -VirtualHost vh1 -$SourceQueueName q1 -$DestinationQueueName q2 -Count 5

   Moves first 5 messages from q1 to q2 on Virtual Host vh1.

.INPUTS

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Move-RabbitMQMessage
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact='High')]
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
        
        $exchange = Get-RabbitMQQueueBinding -VirtualHost $VirtualHost -Name $DestinationQueueName -Credentials $Credentials | ? source -ne "" | select -First 1
    }
    Process
    {
        $s = @{$true=$Count;$false='all'}[$Count -gt 0]
        if ($pscmdlet.ShouldProcess("server: $ComputerName/$VirtualHost", "Move $s messages from queue $SourceQueueName to queue $DestinationQueueName."))
        {
            $m = Get-RabbitMQMessage -Credentials $Credentials -VirtualHost $VirtualHost -Name $SourceQueueName
            $c = $m.message_count + 1

            if ($Count -eq 0 -or $Count -gt $c ) { $Count = $c }
            Write-Verbose "There are $Count messages to be copied."

            for ($i = 1; $i -le $Count; $i++)
            {
                # get message to be copies, but do not remove it from the server yet.
                $m = Get-RabbitMQMessage -Credentials $Credentials -VirtualHost $VirtualHost -Name $SourceQueueName

                # publish message to copying exchange, this will publish it onto dest queue as well as src queue.
                Add-RabbitMQMessage -Credentials $Credentials -VirtualHost $VirtualHost -ExchangeName $exchange.source -RoutingKey $exchange.routing_key -Payload $m.payload -Properties $m.properties

                # remove message from src queue. It has been published step earlier.
                $m = Get-RabbitMQMessage -Credentials $Credentials -VirtualHost $VirtualHost -Name $SourceQueueName -Remove

                Write-Verbose "published message $i out of $Count"
                $cnt++
            }
        }
    }
    End
    {
        Write-Verbose "`r`nMoved $cnt messages from queue $SourceQueueName to queue $DestinationQueueName."
    }
}
