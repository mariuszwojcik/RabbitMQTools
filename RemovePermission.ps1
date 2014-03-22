<#
.Synopsis
   Removes permissions to virtual host for a user.

.DESCRIPTION
   The Remove-RabbitMQPermission cmdlet allows to remove user permissions to virtual host.

   To remove permissions to remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Remove-RabbitMQPermission -VirtualHost '/' -User Admin

   Removes permissions for user Admin to default virtual host (/) on local RabbitMQ server.

.EXAMPLE
   Remove-RabbitMQPermission -ComputerName rabbitmq.server.com '/' Admin

   Removes permissions for user Admin to default virtual host (/) on remote RabbitMQ rabbitmq.server.com.

.INPUTS
   You can pipe VirtualHost, User and ComputerName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQPermission
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
        if ($pscmdlet.ShouldProcess("server: $ComputerName", "Remove permissions to virtual host $VirtualHost for user $User : $Configure, $Read $Write"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/permissions/$([System.Web.HttpUtility]::UrlEncode($VirtualHost))/$([System.Web.HttpUtility]::UrlEncode($User))"
            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Delete

            Write-Verbose "Removed permissions to $VirtualHost for $User : $Configure, $Read, $Write"
            $cnt++
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Removed $cnt permissions." }
    }
}
