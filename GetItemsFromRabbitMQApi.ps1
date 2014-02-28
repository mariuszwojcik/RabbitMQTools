function GetItemsFromRabbitMQApi
{
    Param
    (
        [parameter(Mandatory=$true)]
        [string]$computerName,

        [string]$userName,
        [string]$password,
        
        [parameter(Mandatory=$true)]
        [string]$function
    )

    Add-Type -AssemblyName System.Web
    Add-Type -AssemblyName System.Net
                
    $cred = GetRabbitMqCredentials $userName $password
    $url = "http://$([System.Web.HttpUtility]::UrlEncode($computerName)):15672/api/$function"
    return Invoke-RestMethod $url -Credential $cred
}
