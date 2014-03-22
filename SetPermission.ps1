<#
.Synopsis
   Updates permissions to virtual host for a user.

.DESCRIPTION
   The Set-RabbitMQPermission cmdlet allows to update user permissions to virtual host.

   To update permissions to remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Set-RabbitMQPermission -VirtualHost '/' -User Admin -Configure .* -Read .* -Write .*

   Update configure, read and write permissions for user Admin to default virtual host (/).

.EXAMPLE
   Set-RabbitMQPermission -ComputerName rabbitmq.server.com '/' Admin .* .* .*

   Update configure, read and write permissions for user Admin to default virtual host (/) on server rabbitmq.server.com. This command uses positional parameters.

.INPUTS
   You can pipe VirtualHost, User, Configure, Read, Write and ComputerName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Set-RabbitMQPermission
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param
    (
        # Virtual host to set permission for.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [Alias("vhost", "vh")]
        [string]$VirtualHost,

        # Name of user to set permission for.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [string]$User,

        # Configure permission regexp.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [string]$Configure,

        # Read permission regexp.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=3)]
        [string]$Read,

        # Write permission regexp.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=4)]
        [string]$Write,

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
        
        $p = Get-RabbitMQPermission -ComputerName $ComputerName -Credentials $Credentials -VirtualHost $VirtualHost -User $User
        if (-not $p) { throw "Permissions to virtual host $VirtualHost for user $User do not exist. To create permissions use Add-RabbitMQPermission cmdlet." }
        
        $cnt = 0
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("server: $ComputerName", "Changes permission to virtual host $VirtualHost for user $User : $Configure, $Read $Write"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/permissions/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($User))"
            $body = @{
                'configure' = $Configure
                'read' = $Read
                'write' = $Write                
            } | ConvertTo-Json
            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -Body $body

            Write-Verbose "Changed permission to $VirtualHost for $User : $Configure, $Read, $Write"
            $cnt++
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Changed $cnt permissions." }
    }
}
