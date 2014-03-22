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
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact='None')]
    Param
    (
        # Name of RabbitMQ Queue.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("queue", "QueueName")]
        [string]$Name = "",

        # Name of the virtual host to filter channels by.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("vh", "vhost")]
        [string]$VirtualHost,
        
        # Name of the computer hosting RabbitMQ server. Defalut value is localhost.
        [parameter(ValueFromPipelineByPropertyName=$true)]
        [Alias("HostName", "hn", "cn")]
        [string]$ComputerName = $defaultComputerName,


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
        [int]$Truncate,

        # Indicates what view should be used to present the data.
        [ValidateSet("Default", "Payload", "Details")]
        [string]$View = "Default",
        
        
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
        if (-not $VirtualHost)
        {
            # figure out the Virtual Host value
            $p = @{}
            $p.Add("Credentials", $Credentials)
            if ($ComputerName) { $p.Add("ComputerName", $ComputerName) }
            
            $queues = Get-RabbitMQQueue @p | ? Name -eq $Name

            if (-not $queues) { return; }

            if (-not $queues.GetType().IsArray)
            {
                $VirtualHost = $queues.vhost
            } else {
                $vhosts = $queues | select vhost
                $s = $vhosts -join ','
                Write-Error "Queue $Name exists in multiple Virtual Hosts: $($queues.vhost -join ', '). Please specify Virtual Host to use."
            }
        }


        [string]$s = ""
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

            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Post -ContentType "application/json" -Body $bodyJson

            $result | Add-Member -NotePropertyName "QueueName" -NotePropertyValue $Name

            foreach ($item in $result)
            {
                $cnt++
                $item | Add-Member -NotePropertyName "no" -NotePropertyValue $cnt
                $item | Add-Member -NotePropertyName "ComputerName" -NotePropertyValue $ComputerName
                $item | Add-Member -NotePropertyName "VirtualHost" -NotePropertyValue $VirtualHost
            }

            if ($View)
            {
                switch ($View.ToLower())
                {
                    'payload'
                    {
                        SendItemsToOutput $result "RabbitMQ.QueueMessage" | fc
                    }

                    'details'
                    {
                        SendItemsToOutput $result "RabbitMQ.QueueMessage" | ft -View Details
                    }
                    
                    Default { SendItemsToOutput $result "RabbitMQ.QueueMessage" }
                }
            }
        }
    }
    End
    {
        Write-Verbose "`r`nGot $cnt messages from queue $Name, vhost $VirtualHost, server: $ComputerName."
    }
}

