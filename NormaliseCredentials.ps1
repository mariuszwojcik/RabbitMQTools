function NormaliseCredentials()
{
    switch ($PsCmdlet.ParameterSetName)
    {
        "defaultLogin" { return GetRabbitMqCredentials $defaultUserName $defaultPassword }
        "login" { return GetRabbitMqCredentials $UserName $Password }
        "cred" { return $Credentials }
    }
}
