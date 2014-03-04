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