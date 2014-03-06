$computerNameCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $items = @()
    $items += New-Object System.Management.Automation.CompletionResult "localhost", "localhost", 'ParameterValue', "Local computer"

    $items | where ListItemText -like "$wordToComplete*"
}

$virtualHostCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQVirtualHost @parms | where name -like "$wordToComplete*" | select name | ForEach-Object { 
        $vhname = @{$true="Default"; $false= $_.name}[$_.name -eq "/"]
        $cname = @{$true="localhost"; $false = $fakeBoundParameter.ComputerName}[$fakeBoundParameter.ComputerName -eq $null]
        $tooltip = "$vhname on $cname."
        
        createCompletionResult $_.name $tooltip
    }
}

$exchangeCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.VirtualHost) { $parms.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQExchange @parms | where name -like "$wordToComplete*" | select name | ForEach-Object { 
        $ename = @{$true="(AMQP default)"; $false=$_.name}[$_.name -eq ""]
        $vhname = @{$true="[default]"; $false= $fakeBoundParameter.VirtualHost}[$fakeBoundParameter.VirtualHost -eq "/"]
        $cname = @{$true="localhost"; $false = $fakeBoundParameter.ComputerName}[$fakeBoundParameter.ComputerName -eq $null]
        $tooltip = "$ename on $cname/$vhname."
        
        #New-Object System.Management.Automation.CompletionResult $ename, $ename, 'ParameterValue', $tooltip 
        createCompletionResult $ename $tooltip
    }
}

$connectionCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQConnection @parms | where name -like "$wordToComplete*" | select name | ForEach-Object { 
        $cname = @{$true="localhost"; $false = $fakeBoundParameter.ComputerName}[$fakeBoundParameter.ComputerName -eq $null]
        $tooltip = "$_.name on $cname."
        
        createCompletionResult $_.name $tooltip
    }
}

$nodeCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQNode @parms | where name -like "$wordToComplete*" | select name | ForEach-Object { 
        $cname = @{$true="localhost"; $false = $fakeBoundParameter.ComputerName}[$fakeBoundParameter.ComputerName -eq $null]
        $tooltip = $_.name + " on " + $cname + "."
        
        createCompletionResult $_.name $tooltip
    }
}

$channelCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.VirtualHost) { $parms.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQChannel @parms | where name -like "$wordToComplete*" | select name | ForEach-Object { 
        $cname = @{$true="localhost"; $false = $fakeBoundParameter.ComputerName}[$fakeBoundParameter.ComputerName -eq $null]
        $tooltip = $_.name + " on " + $cname + "."
        
        createCompletionResult $_.name $tooltip
    }
}

$queueCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.VirtualHost) { $parms.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    Get-RabbitMQQueue @parms | where name -like "$wordToComplete*" | select name | ForEach-Object { 
        $cname = @{$true="localhost"; $false = $fakeBoundParameter.ComputerName}[$fakeBoundParameter.ComputerName -eq $null]
        $tooltip = $_.name + " on " + $cname + "."
        
        createCompletionResult $_.name $tooltip
    }
}

$routingKeyCompletion_Process = {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameter)
    
    $parms = @{}
    if ($fakeBoundParameter.ComputerName) { $parms.Add("ComputerName", $fakeBoundParameter.ComputerName) }
    if ($fakeBoundParameter.VirtualHost) { $parms.Add("VirtualHost", $fakeBoundParameter.VirtualHost) }
    if ($fakeBoundParameter.UserName) { $parms.Add("UserName", $fakeBoundParameter.UserName) }
    if ($fakeBoundParameter.Password) { $parms.Add("Password", $fakeBoundParameter.Password) }

    $tooltip = "Bind exchange " + $fakeBoundParameter.ExchangeName + " to queue " + $fakeBoundParameter.Name + "."
        
    createCompletionResult $fakeBoundParameter.Name $tooltip
    createCompletionResult $($fakeBoundParameter.ExchangeName + "-" + $fakeBoundParameter.Name) $tooltip
    createCompletionResult $($fakeBoundParameter.ExchangeName + "->" + $fakeBoundParameter.Name) $tooltip
    createCompletionResult $($fakeBoundParameter.ExchangeName + ".." + $fakeBoundParameter.Name) $tooltip
}

function createCompletionResult([string]$value, [string]$tooltip) {

    if ([string]::IsNullOrEmpty($value)) { return }
    if ([string]::IsNullOrEmpty($tooltip)) { $tooltip = $value }
    
    $completionText = @{$true="'$value'"; $false=$value  }[$value -match "\W"]
    $completionText = $completionText -replace '\[', '``[' -replace '\]', '``]'
    
    return New-Object System.Management.Automation.CompletionResult $completionText, $value, 'ParameterValue', $tooltip 
}



if (-not $global:options) { $global:options = @{CustomArgumentCompleters = @{};NativeArgumentCompleters = @{}}}

$global:options['CustomArgumentCompleters']['Test1:Name'] = $testCompletion_Process 


$global:options['CustomArgumentCompleters']['Get-RabbitMQOverview:Name'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQVirtualHost:Name'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQVirtualHost:ComputerName'] = $computerNameCompletion_Process 
#$global:options['CustomArgumentCompleters']['Add-RabbitMQVirtualHost:Name'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQVirtualHost:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQVirtualHost:Name'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQVirtualHost:ComputerName'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQExchange:Name'] = $exchangeCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQExchange:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQExchange:ComputerName'] = $computerNameCompletion_Process 
#$global:options['CustomArgumentCompleters']['Add-RabbitMQExchange:Name'] = $exchangeCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQExchange:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQExchange:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQExchange:Name'] = $exchangeCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQExchange:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQExchange:ComputerName'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQConnection:Name'] = $connectionCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQConnection:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQConnection:Name'] = $connectionCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQConnection:ComputerName'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQNode:Name'] = $nodeCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQNode:ComputerName'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQChannel:Name'] = $channelCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQChannel:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQChannel:ComputerName'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQQueue:Name'] = $queueCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQQueue:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueue:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQQueue:Name'] = $queueCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQQueue:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Remove-RabbitMQQueue:ComputerName'] = $computerNameCompletion_Process 

$global:options['CustomArgumentCompleters']['Get-RabbitMQQueueBinding:Name'] = $queueCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQQueueBinding:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Get-RabbitMQQueueBinding:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:Name'] = $queueCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:VirtualHost'] = $virtualHostCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:ComputerName'] = $computerNameCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:ExchangeName'] = $exchangeCompletion_Process 
$global:options['CustomArgumentCompleters']['Add-RabbitMQQueueBinding:RoutingKey'] = $routingKeyCompletion_Process

$function:tabexpansion2 = $function:tabexpansion2 -replace 'End\r\n{','End { if ($null -ne $options) { $options += $global:options} else {$options = $global:options}'
