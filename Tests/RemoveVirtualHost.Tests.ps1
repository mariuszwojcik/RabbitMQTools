$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\RemoveVirtualHost.ps1"

Describe -Tags "Example" "Remove-RabbitMQVirtualHost" {
    It "should remove existing Virtual Host" {

        Add-RabbitMQVirtualHost -ComputerName $server "vh3"
        Remove-RabbitMQVirtualHost -ComputerName $server "vh3" -Confirm:$false
        
        $actual = Get-RabbitMQVirtualHost -ComputerName $server "vh*" | select -ExpandProperty name 
        
        $actual | Should Be $("vh1", "vh2")
    }
}