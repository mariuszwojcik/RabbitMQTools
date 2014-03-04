$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\AddExchange.ps1"

function TearDownTest() {
    
    $exchanges = Get-RabbitMQExchange -ComputerName $server e1, e2

    ($exchanges) | Remove-RabbitMQExchange -ComputerName $server -ErrorAction Continue -Confirm:$false
}

Describe -Tags "Example" "Add-RabbitMQExchange" {
    It "should create new Exchange" {
    
        Add-RabbitMQExchange -ComputerName $server -Type direct e1
        
        $actual = Get-RabbitMQExchange -ComputerName $server e1 | select -ExpandProperty name 
        
        $actual | Should Be "e1"
    
        TearDownTest
    }
    
    It "should do nothing when Exchange already exists" {
    
        Add-RabbitMQExchange -ComputerName $server -Type direct "e1"
        Add-RabbitMQExchange -ComputerName $server -Type direct "e1"
    
        $actual = Get-RabbitMQExchange -ComputerName $server "e1" | select -ExpandProperty name 
        
        $actual | Should Be "e1"
    
        TearDownTest
    }
    
    It "should create many Exchanges" {
    
        Add-RabbitMQExchange -ComputerName $server -Type direct e1,e2
    
        $actual = Get-RabbitMQExchange -ComputerName $server e1,e2 | select -ExpandProperty name 
    
        $expected = $("e1", "e2")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
    
    It "should get Exchange to be created from the pipe" {
    
        $("e1", "e2") | Add-RabbitMQExchange -ComputerName $server -Type direct
        
        $actual = $($("e1", "e2") | Get-RabbitMQExchange -ComputerName $server) | select -ExpandProperty name 
    
        $expected = $("e1", "e2")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
    
    It "should get Exchange with properties to be created from the pipe" {
    
        $pipe = $(
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "e1"; "Type" = "direct" }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "e2"; "Type" = "fanout" }
        )
    
        $pipe | Add-RabbitMQExchange
    
        $actual = $($pipe | Get-RabbitMQExchange -ComputerName $server) | select -ExpandProperty name 
    
        $expected = $("e1", "e2")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
}
