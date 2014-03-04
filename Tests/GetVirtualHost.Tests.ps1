$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\TestSetup.ps1"
. "$here\..\GetVirtualHost.ps1"

Describe -Tags "Example" "Get-RabbitMQVirtualHost" {

    It "should get Virtual Hosts registered with the server" {

        $actual = Get-RabbitMQVirtualHost -ComputerName $server | select -ExpandProperty name 

        $expected = $("/", "vh1", "vh2")

        AssertAreEqual $actual $expected
    }

    It "should get Virtual Hosts filtered by name" {

        $actual = Get-RabbitMQVirtualHost -ComputerName $server vh* | select -ExpandProperty name 

        $expected = $("vh1", "vh2")

        AssertAreEqual $actual $expected
    }

    It "should get VirtualHost names to filter by from the pipe" {

        $actual = $('vh1', 'vh2') | Get-RabbitMQVirtualHost -ComputerName $server | select -ExpandProperty name 

        $expected = $("vh1", "vh2")

        AssertAreEqual $actual $expected
    }

    It "should get VirtualHost and ComputerName from the pipe" {

        $pipe = $(
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "vh1" }
            New-Object -TypeName psobject -Prop @{"ComputerName" = $server; "Name" = "vh2" }
        )

        $actual = $pipe | Get-RabbitMQVirtualHost | select -ExpandProperty name 

        $expected = $("vh1", "vh2")

        AssertAreEqual $actual $expected
    }

    It "should pipe result from itself" {

        $actual = Get-RabbitMQVirtualHost -ComputerName $server | Get-RabbitMQVirtualHost | select -ExpandProperty name 

        $expected = Get-RabbitMQVirtualHost -ComputerName $server | select -ExpandProperty name 

        AssertAreEqual $actual $expected
    }
}

