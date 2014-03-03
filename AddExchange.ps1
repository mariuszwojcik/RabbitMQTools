function Add-RabbitMQExchange
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Medium")]
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
    }
    Process
    {
        #if ($VirtualHost -eq "/") {
        #    throw "Invalid Virtual Host. Currently it is not possible to create exchanges in ""/"" Virtual Host. Please specify different virtual host."
        #}

        if ($pscmdlet.ShouldProcess("server: $ComputerName, vhost: $VirtualHost", "Add exchange(s): $(NamesToString $Name '(all)')")) {
            
            $body = @{
                type = "$Type"
                durable = $Durable = $true
                "auto_delete"=$AutoDelete= $true
                internal=$Internal= $true
            }

            if ($AlternateExchange) {
                $a = @{ 
                    "alternate-exchange"=$AlternateExchange 
                }
                $body.Add("arguments", $a)    
            }

            $bodyJson = $body | ConvertTo-Json

            foreach($n in $Name)
            {
                $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/exchanges/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($n))"
                Write-Verbose $url
        
                $result = Invoke-RestMethod $url -Credential $cred -ErrorAction Continue -Method Put -ContentType "application/json" -Body $bodyJson

                Write-Verbose "Created Exchange $n on server $ComputerName, Virtual Host $VirtualHost"
                $cnt++
            }
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Created $cnt Virtual Host(s)." }
    }
}
