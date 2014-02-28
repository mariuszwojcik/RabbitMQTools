function GetRabbitMQCredentials
{
    Param
    (
        [parameter(Mandatory=$true)]
        [string]$userName,
        
        [parameter(Mandatory=$true)]
        [string]$password
    )

    $secpasswd = ConvertTo-SecureString $password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential ($userName, $secpasswd)
}