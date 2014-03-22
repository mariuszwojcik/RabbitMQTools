<#
.Synopsis
   Adds Virtual Hosts to RabbitMQ server.

.DESCRIPTION
   The Add-RabbitMQVirtualHost allows for creating new Virtual Hosts in given RabbitMQ server.

   To add Virtual Hosts to remote server you need to provide -ComputerName.

   You may pipe an object with names and, optionally, with computer names to create multiple VirtualHosts. For more information how to do that see Examples.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Add-RabbitMQVirtualHost testHost

   This command adds new Virtual Host named "testHost" to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQVirtualHost VHost1, VHost2

   This command adds two new Virtual Hosts named "VHost1" and "VHost2" to local RabbitMQ server.

.EXAMPLE
   Add-RabbitMQVirtualHost testHost -ComputerName myrabbitmq.servers.com

   This command adds new Virtual Host named "testHost" to myrabbitmq.servers.com server.

.EXAMPLE
   @("VHost1", "VHost2") | Add-RabbitMQVirtualHost

   This command pipes list of Virtual Hosts to add to the RabbitMQ server. In the above example two new Virtual Hosts named "VHost1" and "VHost2" will be created in local RabbitMQ server.

.EXAMPLE
    $a = $(
        New-Object -TypeName psobject -Prop @{"ComputerName" = "localhost"; "Name" = "vh1"}
        New-Object -TypeName psobject -Prop @{"ComputerName" = "localhost"; "Name" = "vh2"}
        New-Object -TypeName psobject -Prop @{"ComputerName" = "127.0.0.1"; "Name" = "vh3"}
    )


   $a | Add-RabbitMQVirtualHost

   Above example shows how to pipe both Virtual Host name and Computer Name to specify server on which the Virtual Host should be created.
   
   In the above example two new Virtual Hosts named "vh1" and "vh1" will be created in RabbitMQ local server, and one Virtual Host named "vh3" will be created on the server 127.0.0.1.

.INPUTS
   You can pipe VirtualHost names and optionally ComputerNames to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Add-RabbitMQVirtualHost
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="Low")]
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
            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json"

            Write-Verbose "Created Virtual Host $n on server $ComputerName"
            $cnt++
        }
    }
    End
    {
        Write-Verbose "Created $cnt Virtual Host(s)."
    }
}
