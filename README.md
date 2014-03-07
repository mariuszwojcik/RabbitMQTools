RabbitMQTools
=============

This module provides set of cmdlets to manage RabbitMQ.

## Getting started

Clone the repository to your local drive and then import it to PowerShell

    cd .\path_to_module_directy
    Import-Module RabbitMQTools

Alternatively, if you want the module to be imported automatically every time new PowerShell session is started then clone the repository to your modules path. To find the path run

    $env:PSModulePath -split ';'
	
and clone the repository to the path under your documents.

## What can I do with it?

There is a set of cmdlets to manage the server, such as:

- Get-RabbitMQOverview
- Get-RabbitMQNode
- Get-RabbitMQConnection
- Get-RabbitMQChannel
- Get-RabbitMQVirtualHost, Add-RabbitMQVirtualHost, Remove-RabbitMQVirtualHost
- Get-RabbitMQExchage, Add-RabbitMQExchange, Remove-RabbitMQExchange
- Get-RbbitMQQueue, Add-RabbitMQQueue, Remove-RabbitMQQueue
- Get-RabbitMQMessage

To learn more about a cmdlet, or to see some examples run get-hel cmdlet_name
