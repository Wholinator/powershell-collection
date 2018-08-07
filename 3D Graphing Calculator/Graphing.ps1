# This project was an exploration of the possibilities of generating images with powershell
# It is an exercise in using the tools available to accomplish complex tasks
#
# The text output of this file is meant to be converted to a csv and placed in excel
# Then conditional gradient color formatting is applied and all the cells are sized
# down to reveal the final image. Hopefully something interesting


# necessary for pesky trigonometric functions that I did not have time to program myself
[math].getMethods() | select name -unique

# main function for processing interesting images
Function FofXY  {
    param($x,$y)

    try {
		# perfors our function on the supplied coordinates to get our 3D posititioning for image processing
	
        #(power (($x * $y) + 1) 3) / (1 - (sqrt ($x * $y)))
        #($x * (power $y 3)) - ($y * (power $x 3))
       [math]::floor(-[math]::exp((-$x) * $y) * [math]::cos(((power $x 2) + (power $y 2)) / 10)) + (14 * [math]::log(10000 / (power $x 2) + (power $y 2) + 0.01)) * [math]::floor([math]::cos((power $x 2) + (power $y 2)) / 10) + (3 * ([math]::Ceiling($x) - [math]::floor($y)) * ([math]::ceiling($y) - [math]::floor($y))) 
    } catch {
        return "N/A"
    }
}

# performs the computational derivative of a function between 2 points
Function Der {
    param($a, $b)
    $h = 0.0000001

    try {
        $out = FofXY $a $b
        $aph = $a + $h
        $bph = $b + $h
        $out2 = FofXY $aph $b

        return (($out2 - $out) / $h)
    } catch {
        return "N/A"
    }
}

# performs the computational second derivative of a function between 2 points
Function 2Der {
    param($a, $b)
    $h = 0.0001

    try {
        $out = FofXY $a $b
        $aph1 = $a + $h
        $aph2 = $a - $h

        $result = (FofXY $aph1 $b) - (2*($out)) + (FofXY $aph2 $b)
        
        return $result / (power $h 2)  
    } catch {
        return "N/A"
    }
}

# performs the integral of a function between 2 points
Function Integrate {
    param($a, $b)
    

    $aph = 0
    $bph = 0

    $diff = $a * $b

    $out = FofXY $a $b
    $out1 = FofXY 0 0

    $outF = ($out1 + $out) / 2

    $outF *= ($diff)

    return $outF
}

# performs the iterative computational square root of a number
Function Sqrt {
    param($a, $steps)

    if($steps -eq $null) {
        $steps = 20
    }

    $x = 1

    $list = 1..$steps
    foreach($i in $list) {
        $x = ($x + ($a / $x)) / 2
    }
    return $x
}

# raises a number to a power
Function Power {
    param($a, $n)
    $result = 1
    for($i=0;$i -lt $n;$i++) {
        $result *= $a
    } return $result
}

# set up our desired resolution and output file
$pixelHeight = 176*5
$pixelWidth = 328*5
$trueWidth = 10
$file = "C:\users\dt216416\desktop\output.txt"
Clear-Content $file


# center the resolution on (0,0)
$xlist = -($pixelheight/2)..($pixelheight/2)
$ylist = -($pixelwidth/2)..($pixelwidth/2)

$divisor = 10

foreach($x in $xlist) {
    $zArr = @()
    $xAdj = $x / $divisor

    foreach($y in $ylist) {
	
		# convert the pixel to cartesian coordinates for functional processing
        $yadj = $y / $divisor
        $xAdj = ($x / $pixelwidth) * $trueWidth
        $yAdj = ($y / $pixelwidth) * $trueWidth

		# assigns to $z our desired function or derivative or integral on the function of $x and $y
        $z = Der $xadj $yadj ### PUT THE CURRENT OUTPUT INTO THE EXCEL PICTURES, THEN DO THE DER FUNCTION IN THE SAME RESOLUTION AND PUT IT IN THE PICTURES TOO ###
        $zArr += $z

        Write-Host "$xAdj, $yAdj"
    }
    $s = ""
	
	#concatenates necessary $z values
    foreach($z in $zarr) {
        if($z -eq $zarr[$zarr.length-1]) {
            $s += $z
        } else {
            $s += "$z, "
        }
    } $s | out-File -filepath $file -append  
}



