function Sync-Folder
{
    
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory=$True)]
        [string]$SourceFolder,
        [parameter(Mandatory=$True)]
        [string]$TargetFolder
    )

    function Sync-OneFolder
    {
        param
        (
            [parameter(Mandatory=$True)]
            [ValidateScript({Test-Path $_ -PathType container})]
            [string]$SourceFolder,
            [parameter(Mandatory=$True)]
            [ValidateScript({Test-Path $_ -IsValid })]
            [string]$TargetFolder
        )

        $timespan = new-timespan -days 30
        $currentDate = (get-date)

        #create destination folder if it does not exist
        if(!(Test-Path -Path $Targetfolder -PathType Container))
        {
            New-Item $Targetfolder -ItemType "Directory"
        }

        $SourceList = Get-ChildItem $SourceFolder
        $TargetList = Get-ChildItem $TargetFolder
        
        #populate empty array to avoid null errors between gci and compare-object
        $SourceFiles    = $TargetFiles = @()                        
        $SourceFolders  = $TargetFolders = @()                    
        $SourceFiles   += $SourceList | where{!($_.PSIsContainer)}
        $TargetFiles   += $TargetList | where{!($_.PSIsContainer)}
        $SourceFolders += $SourceList | where{$_.PSIsContainer}
        $TargetFolders += $TargetList | where{$_.PSIsContainer}

        $MissingFiles   = Compare-Object $Sourcefiles   $TargetFiles   -Property Name
        $MissingFolders = Compare-Object $SourceFolders $TargetFolders -Property Name

        
        foreach($Missingfile in $MissingFiles)
        {
            #ADD File from Source that's not in Target
            if($MissingFile.SideIndicator -eq "<=") 
            {
                $lastWrite = (get-item ($SourceFolder + "\" + $MissingFile.name)).LastWriteTime
                
                if(($CurrentDate - $lastWrite) -lt $timespan)
                {   
                    Write-Verbose "Copying missing file : $($TargetFolder+"\"+$MissingFile.Name)"
                    Copy-Item ($SourceFolder + "\" + $MissingFile.Name) ($TargetFolder + "\" + $MissingFile.Name)
                }
            } 
            #REMOVE File in Target that's not in Source
            elseif($MissingFile.SideIndicator -eq "=>")
            {
                Write-Verbose "Removing extraneous file : $($Targetfolder + "\" + $MissingFile.Name)"
                Remove-Item($TargetFolder + "\" + $MissingFile.Name)
            }    
        }

        foreach($Missingfolder in $MissingFolders)
        {
            #REMOVE Folder in Target that's not in Source
            if($MissingFolder.SideIndicator -eq "=>")
            {
                Write-Verbose "Removing extraneous folder : $($TargetFolder + "\" + $MissingFile.Name)"
                Remove-Item ($TargetFolder + "\" + $MissingFolder.Name) -recurse -confirm:$false
            }
        }

        foreach($SourceFile in $SourceFiles) 
        {
            $lastWrite = (get-item ($SourceFolder + "\" + $Sourcefile.Name)).LastWriteTime

            if(($currentDate - $lastWrite) -lt $timespan)
            {
                 #Update file in Target from current file in Source
                if($SourceFile.LastWriteTime -gt (Get-ChildItem ($TargetFolder + "\" + $SourceFile.Name)).LastWritetime)
                {
                    Write-Verbose "Copying updated file : $($Sourcefolder + "\" + $SourceFile.Name)"
                    Copy-Item ($SourceFolder + "\" + $SourceFile.Name) ($TargetFolder + "\" + $SourceFile.Name) -Force
                }
            }
            

        }

        #Recurse into all subdirectories
        foreach($SingleFolder in $Sourcefolders)
        {
            Sync-OneFolder $SingleFolder.FullName ($TargetFolder + "\" + $SingleFolder.Name)
        }
    }
    Sync-OneFolder $SourceFolder $TargetFolder 
}