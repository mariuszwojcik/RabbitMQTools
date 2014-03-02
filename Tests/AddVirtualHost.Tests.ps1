$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\..\AddVirtualHost.ps1"

$server = "192.168.232.129"

function AssertAreEqual($actual, $expected) {

    if ($actual -is [System.Array]) {
        if ($expected -isnot [System.Array]) { throw "Expected {$expected} to be an array, but it is not." }

        if ($actual.Length -ne $expected.Length)
        { 
            $al = $actual.Length
            $el = $expected.Length
            throw "Expected $al elements but were $el"
        }

        for ($i = 0; $i -lt $actual.Length; $i++)
        {
            $a = $actual[$i]
            $e = $expected[$i]
            if ($a -ne $e) 
            { 
                throw "Expected element at position $i to be {$e} but was {$a}" 
            }
        }
    }
}

function TearDownTest() {
    
    $vhosts = Get-RabbitMQVirtualHost -ComputerName $server vh3, vh4

    ($vhosts) | Remove-RabbitMQVirtualHost -ComputerName $server -ErrorAction Continue -Confirm:$false
}

Describe -Tags "Example" "Add-RabbitMQVirtualHost" {
    It "should create new Virtual Host" {
    
        Add-RabbitMQVirtualHost -ComputerName $server "vh3"
        
        $actual = Get-RabbitMQVirtualHost -ComputerName $server "vh3" | select -ExpandProperty name 
        
        $actual | Should Be "vh3"
    
        TearDownTest
    }
    
    It "should do nothing when VirtualHost already exists" {
    
        Add-RabbitMQVirtualHost -ComputerName $server "vh3"
        Add-RabbitMQVirtualHost -ComputerName $server "vh3"
    
        $actual = Get-RabbitMQVirtualHost -ComputerName $server "vh3" | select -ExpandProperty name 
        
        $actual | Should Be "vh3"
    
        TearDownTest
    }
    
    It "should create many Virtual Hosts" {
    
        Add-RabbitMQVirtualHost -ComputerName $server "vh3", "vh4"
    
        $actual = Get-RabbitMQVirtualHost -ComputerName $server "vh3", "vh4" | select -ExpandProperty name 
    
        $expected = $("vh3", "vh4")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
    
    It "should get VirtualHost to be created from the pipe" {
    
        $("vh3", "vh4") | Add-RabbitMQVirtualHost -ComputerName $server
        
        $actual = $($("vh3", "vh4") | Get-RabbitMQVirtualHost -ComputerName $server) | select -ExpandProperty name 
    
        $expected = $("vh3", "vh4")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
    
    It "should get VirtualHost with ComputerName to be created from the pipe" {
    
        $pipe = $(
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "vh3" }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "vh4" }
        )
    
        $pipe | Add-RabbitMQVirtualHost
    
        $actual = $($pipe | Get-RabbitMQVirtualHost -ComputerName $server) | select -ExpandProperty name 
    
        $expected = $("vh3", "vh4")
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }
}

