$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\RemoveExchange.ps1"

Describe -Tags "Example" "Remove-RabbitMQExchange" {
    It "should remove existing Exchange" {

        Add-RabbitMQExchange -ComputerName $server "e1" -Type direct
        Remove-RabbitMQExchange -ComputerName $server "e1" -Confirm:$false
        
        $actual = Get-RabbitMQExchange -ComputerName $server e1 | select -ExpandProperty name 
        
        $actual | Should Be $()
    }
}