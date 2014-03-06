$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\AddQueue.ps1"

function TearDownTest() {
    
    $queues = Get-RabbitMQQueue -ComputerName $server -VirtualHost test

    ($queues) | Remove-RabbitMQQueue -ComputerName $server -VirtualHost test -ErrorAction Continue -Confirm:$false
}

Describe -Tags "Example" "Add-RabbitMQQueue" {

    It "should create new Queue" {
    
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1
        
        $actual = Get-RabbitMQQueue -ComputerName $server -VirtualHost test q1 | select -ExpandProperty name 
        
        $actual | Should Be "q1"
    
        TearDownTest
    }

    It "should create Durable new Queue" {
    
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1 -Durable
        
        $actual = Get-RabbitMQQueue -ComputerName $server -VirtualHost test q1 | select -ExpandProperty durable
        
        $actual | Should Be $true
    
        TearDownTest
    }

    It "should create AutoDelete new Queue" {
    
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1 -AutoDelete
        
        $actual = Get-RabbitMQQueue -ComputerName $server -VirtualHost test q1 | select -ExpandProperty auto_delete
        
        $actual | Should Be $true
    
        TearDownTest
    }

    It "should create Durable, AutoDelete new Queue" {
    
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1 -Durable -AutoDelete

        $actual = Get-RabbitMQQueue -ComputerName $server -VirtualHost test q1 | select -ExpandProperty durable
        $actual | Should Be $true
        
        $actual = Get-RabbitMQQueue -ComputerName $server -VirtualHost test q1 | select -ExpandProperty auto_delete
        $actual | Should Be $true
    
        TearDownTest
    }

    It "should do nothing when Queue already exists" {
    
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1
    
        $actual = Get-RabbitMQQueue -ComputerName $server -VirtualHost test q1 | select -ExpandProperty name 
        $actual | Should Be "q1"
    
        TearDownTest
    }

    It "should create many Queues" {
    
        Add-RabbitMQQueue -ComputerName $server -VirtualHost test q1,q2,q3
    
        $actual = Get-RabbitMQQueue -ComputerName $server "q*" | select -ExpandProperty name 
    
        $expected = $("q1", "q2", "q3")
        AssertAreEqual $actual $expected
    
        TearDownTest
    }

    It "should get queue names from the pipe" {
    
        $pipe = $("q1", "q1") 
        
        $pipe| Add-RabbitMQQueue -ComputerName $server -VirtualHost test
        
        $actual = $($pipe | Get-RabbitMQQueue -ComputerName $server -VirtualHost test) | select -ExpandProperty name 
    
        $expected = $pipe
    
        AssertAreEqual $actual $expected
    
        TearDownTest
    }

    It "should get queue definitions from the pipe" {
    
        $pipe = $(
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "VirtualHost" = "test"; "Name" = "q1" }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "VirtualHost" = "test"; "Name" = "q2"; "Durable" = $true }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "VirtualHost" = "test"; "Name" = "q3"; "AutoDelete" = $true }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "VirtualHost" = "test"; "Name" = "q4"; "Durable" = $true; "AutoDelete" = $true }
        )
    
        $pipe | Add-RabbitMQQueue
    
        $actual = $pipe | Get-RabbitMQQueue -ComputerName $server
        
        foreach ($e in $pipe)
        {
            $a = $actual | ? name -eq $e.Name

            $a | Should Not Be $null
            $a.vhost | Should Be $e.VirtualHost
            if ($e.Durable) { $a.durable | Should Be $true }
            if ($e.AutoDelete) { $a.auto_delete | Should Be $true }
        }
    
        TearDownTest
    }

}