function Add-RabbitMQVirtualHost
{
    [CmdletBinding(SupportsShouldProcess=$true, ConfirmImpact="Low")]
    Param
    (
        # Name of RabbitMQ Virtual Host.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vh", "VirtualHost")]
        [string[]]$Name = "",

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
        if (-not $pscmdlet.ShouldProcess("server: $ComputerName", "Add vhost(s): $(NamesToString $Name '(all)')")) {
            foreach ($qn in $Name) 
            { 
                Write "Creating new Virtual Host $qn on server $ComputerName" 
                $cnt++
            }

            return
        }

        foreach($n in $Name)
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/vhosts/$([System.Web.HttpUtility]::UrlEncode($n))"
            $result = Invoke-RestMethod $url -Credential $cred -ErrorAction Continue -Method Put -ContentType "application/json"

            Write-Verbose "Created Virtual Host $n on server $ComputerName"
            $cnt++
        }
    }
    End
    {
        Write-Verbose "Created $cnt Virtual Host(s)."
    }
}
