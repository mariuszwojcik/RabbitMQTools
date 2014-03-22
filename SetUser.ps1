<#
.Synopsis
   Adds user to RabbitMQ server.

.DESCRIPTION
   The Set-RabbitMQUser cmdlet allows to create new users in RabbitMQ server.

   To add a user to remote server you need to provide -ComputerName.

   The cmdlet is using REST Api provided by RabbitMQ Management Plugin. For more information go to: https://www.rabbitmq.com/management.html

   To support requests using default virtual host (/), the cmdlet will temporarily disable UnEscapeDotsAndSlashes flag on UriParser. For more information check get-help about_UnEsapingDotsAndSlashes.

.EXAMPLE
   Set-RabbitMQUser -Name Admin -NewPassword p4ssw0rd -Tag administrator

   Create new user with name Admin having administrator tags set. User is added to local RabbitMQ server.

.EXAMPLE
   Set-RabbitMQUser -ComputerName rabbitmq.server.com Admin p4ssw0rd administrator

   Create new user with name "Admin", password "p4ssw0rd" having "administrator" tags set. User is added to rabbitmq.server.com server. This command uses positional parameters.
   Note that password for new user is specified as -NewPassword parameter and not -Password parameter, which is used for authorisation to the server.

.INPUTS
   You can pipe Name, NewPassword, Tags and ComputerName to this cmdlet.

.LINK
    https://www.rabbitmq.com/management.html - information about RabbitMQ management plugin.
#>
function Set-RabbitMQUser
{
    [CmdletBinding(DefaultParameterSetName='defaultLogin', SupportsShouldProcess=$true, ConfirmImpact="Medium")]
    Param
    (
        # Name of user to update.
        [parameter(Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string]$Name,

        # New password for user.
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [string]$NewPassword,

        # Comma-separated list of user tags.
        [parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true, Position=2)]
        [ValidateSet("administrator", "monitoring", "policymaker", "management")]
        [string[]]$Tag,

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
        
        $user = Get-RabbitMQUser -Credentials $Credentials -ComputerName $ComputerName -Name $Name
        if (-not $user) { throw "User $Name doesn't exist in server $ComputerName" }
        
        $cnt = 0
    }
    Process
    {
        if ($pscmdlet.ShouldProcess("server: $ComputerName", $(GetShouldProcessText)))
        {
            $url = "http://$([System.Web.HttpUtility]::UrlEncode($ComputerName)):15672/api/users/$([System.Web.HttpUtility]::UrlEncode($Name))"
            $body = @{}

            if ($NewPassword) { $body.Add("password", $NewPassword) }
            if ($Tag) { $body.Add("tags", $Tag -join ',') } else { $body.Add("tags", $user.tags) }
            $bodyJson = $body | ConvertTo-Json
            $result = Invoke-RestMethod $url -Credential $Credentials -AllowEscapedDotsAndSlashes -DisableKeepAlive -ErrorAction Continue -Method Put -ContentType "application/json" -Body $bodyJson

            Write-Verbose "Update user $User"
            $cnt++
        }
    }
    End
    {
        if ($cnt -gt 1) { Write-Verbose "Updated $cnt new users." }
    }
}

function GetShouldProcessText
{
    $str = "Update "
    if ($NewPassword -and $Tags) { $str += "password and tags" }
    if ($NewPassword) { $str += "password " }
    if ($Tag) { $str += "tags" }

    $str += " for user $user."

    if ($Tag) { $str += "New tags: $Tag" }

    return $str
}
