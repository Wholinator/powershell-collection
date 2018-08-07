# Rudimentary Markov-Chain coded up in a few hours

Function Init-Markov {
    [CmdletBinding()]
    param([string]$file)

    try 
    { 
        $fileContents = Get-Content $file

        $dictionary = @{}

        Write-Verbose "Building 1 Word Dictionary"
        $dictionary = (Get-Dictionary $fileContents)

        Write-Verbose "Building 2 Word Dictionary"
        $dictionary2 = (Get-Dictionary2 $fileContents)

        Write-Verbose "Building 1 Word TotalUse"
        $totalUseDict = (Get-UseList $dictionary)

        Write-Verbose "Building 2 Word TotalUse"
        $totalUseDict2 = (Get-UseList $dictionary2)
    } 
    catch 
    {
        $_.Exception | Select -property *
    }
}

##################################  CREATE THE DICTIONARY #####################################
Function Get-Dictionary {
    [CmdletBinding()]
    param([System.Array]$filecontents)

    $wordsArray = $fileContents.Split(" ")

    $currentWord = $wordsArray[0]
    $wordsArray = $wordsArray[1..$wordsArray.length]

    $dictionary = @{}
    $totalUseDict = @{}

    $count = 0
    foreach ($word in $wordsArray) {
        $count += 1
        
        #strip some punctuation and make words gooder
        $word = $word -replace "`t|`n|`r",""
        $word = $word.Trim("'",'"')
        if ($word -match '[\d+]{1,3}[:][\d+]{1,3}') {
            continue
        } elseif ($word -eq "") {
            continue
        }

        if (!($dictionary.containsKey($currentWord))) {
            $dictionary[$currentWord] = @{$word = 1}
        } else {
            if ($dictionary[$currentWord].containsKey($word)) {
                $dictionary[$currentWord][$word] += 1
            } else {
                $dictionary[$currentWord] += @{$word = 1}
            }
        }
        $currentWord = $word

        write-progress -Activity "Building One Word Dictionary (Step 1 of 4)" -Status "$count / $($wordsArray.length)" -PercentComplete (($count / $wordsArray.length)*100)
    }
    return $dictionary
}
##################################  TWO WORD DICTIONARY ########################################
Function Get-Dictionary2 {
    [CmdletBinding()]
    param([System.Array]$fileContents)

    $wordsArray = $fileContents.Split(" ")

    $currentWords = $wordsArray[0] + " " + $wordsArray[1]
    $wordsArray = $wordsArray[2..$wordsArray.length]

    $dictionary2 = @{}
    $totalUseDict2 = @{}

    $count = 0
    foreach ($word in $wordsArray) {
        $count += 1

        #strip some punctuation and make words gooder
        $word = $word -replace "`t|`n|`r",""
        $word = $word.Trim("'",'"')
        if ($word -match '[\d+]{1,3}[:][\d+]{1,3}') {
            continue
        } elseif ($word -eq "") {
            continue
        }
    

        if(!($dictionary2.containsKey($currentWords))) {
            $dictionary2[$currentWords] = @{$word = 1}
        } else {
            if ($dictionary2[$currentWords].containsKey($word)) {
                $dictionary2[$currentWords][$word] += 1
            } else {
                $dictionary2[$currentWords] += @{$word = 1}
            }
        }
        $currentWords = $currentWords.Split(" ")[1] + " " + $word

        Write-Progress -Activity "Building Two Word Dictionary (Step 2 of 4)" -Status "$count / $($wordsArray.length)" -PercentComplete (($count / $wordsArray.length)*100)
    }
    return $dictionary2
}



############## CREATE A LIST OF SUM INDEXES FOR EACH 1ST TIER WORD ###################
Function Get-UseList {
    [CmdletBinding()]
    param([Hashtable]$dictionary)

    $totalUseDict = @{}

    $count = 0
    foreach ($word in ($dictionary.getEnumerator() | Select name)) {
        $count += 1
        
        $sum = 0
        $nums = ($dictionary[$word.name].getEnumerator() | select value).value #done to avoid calling the 'values' value instead of enumerating the actual values
    
        $nums | % { $sum += $_}

        $totalUsedict[$word.name] = $sum

        Write-Progress -Activity "Building One Word Total Use List (Step 3 of 4)" -Status "$count / $($dictionary.get_Count())" -PercentComplete (($count / $dictionary.get_Count())*100)
    }
    return $totalUseDict
}

############## CREATE A LIST OF SUM INDEXES FOR 2 WORDS ###################
Function Get-UseList2 {
    [CmdletBinding()]
    param([Hashtable]$dictionary2)

    $totalUseDict2 = @{}

    $count = 0
    foreach ($words in ($dictionary2.GetEnumerator() | Select name)) {
        $count += 1
        
        $sum = 0
        $nums = ($dictionary2[$words.name].getEnumerator() | select value).value

        $nums | % { $sum += $_ }

        $totalUsedict2[$words.name] = $sum

        Write-Progress -Activity "Building Two Word Total Use List (Step 4 of 4)" -Status "$count / $($dictionary2.get_Count())" -PercentComplete (($count / $dictionary2.get_Count())*100)
    }
    return $totalUseDict2
}



######################### MAKE WORDS #################################
Function Get-Markov {
    [CmdletBinding()]
    param([string]$start, [int]$length)

    $totalString = $start
    $currentWord = $start

    $numList = 1..$length

    foreach($n in $numList) {
        $currentWord = Get-NextMarkov $currentWord
        $totalString = $totalString + " " + $currentWord
    } 
"FINAL STRING: " + $totalString
}

Function Get-Markov2 {
    [CmdletBinding()]
    param([string]$start, [int]$length)

    $totalString = $start
    $currentword = $start

    $numlist = 1..$length

    foreach($n in $numlist) {
        $currentWord = Get-NextMarkov2 $currentword
        $totalString = $totalString + " " + $currentWord
    }
"FINAL STRING: " + $totalString
}

Function Get-NextMarkov {
    [CmdletBinding()]
    param([string]$currentword)
    
    if ($totalUseDict[$currentword] -eq 1) {
        $word = ($dictionary[$currentWord].getEnumerator() | select Name).name
        $totalString += " " + $word
        $currentWord = $word
        return $word
    }
    
    $rand = Get-Random -minimum 1 -maximum $totalUseDict[$currentWord]

    $nextList = $dictionary[$currentWord].GetEnumerator() | Select Name

    foreach ($word in $nextList.name) {
        $rand -= $dictionary[$currentWord][$word]

        if($rand -lt 1) {
            $totalString += " " + $word
            $currentWord = $word
            Write-Verbose "MOVING UP: $totalString"
            return $word 
        }
        Write-Verbose "$totalString $word"
    }
}

Function Get-NextMarkov2 {
    [CmdletBinding()]
    param([string]$currentwords)

    if(!($dictionary2.containsKey($currentwords))) {
        if(!($dictionary.containsKey($currentwords))) {
            throw 'STARTING WORDS DO NOT EXIST! CHOOSE SOMETHING THAT DOES'
        }
        return Get-NextMarkov $currentWords
    }
    
    if ($totalUseDict2[$currentwords] -eq 1) {
        $word = ($dictionary2[$currentWords].getEnumerator() | select Name).name
        return $word
    }
    
    $rand = Get-Random -minimum 1 -maximum $totalUseDict2[$currentWords]

    $nextList = $dictionary2[$currentWords].GetEnumerator() | Select Name

    foreach ($word in $nextList.name) {
        $rand -= $dictionary2[$currentWords][$word]

        if($rand -lt 1) {
            Write-Verbose "MOVING UP: $totalString"
            return $word 
        }
        Write-Verbose "$totalString $word"
    }
} 