<#
.Synopsis
   Removes user from RabbitMQ server.

.DESCRIPTION
   The Remove-RabbitMQUser cmdlet allows to delete users from RabbitMQ server.

   To remove a user from remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Remove-RabbitMQUser -Name Admin

   Deletes user "Admin"from local RabbitMQ server.

.EXAMPLE
   Remove-RabbitMQUser -ComputerName rabbitmq.server.com Admin

   Deletes user "Admin" from rabbitmq.server.com server. This command uses positional parameters.

.INPUTS
   You can pipe Name and ComputerName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Remove-RabbitMQUser
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="High")]
    Param
    (
        # Name of user to delete.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string]$Name,

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
        if ($pscmdlet.ShouldProcess("server: $ComputerName", "Delete user $Name"))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/users/$([System.Web.HttpUtility]::UrlEncode($Name))"
            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Delete -ContentType "application/json"

            Write-Verbose "Deleted user $User"
            $cnt++
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Deleted $cnt users." }
    }
}
