
Function checkFilestatus
{
 	Param($k)	
		Try
		{	
        [IO.File]::OpenRead($k).Close()
		Copy-Item -Path "$k" -Destination "D:\ftp\" -Force
		}
		catch
		{
		Start-Sleep -Seconds 120
		Copy-Item -Path "$k" -Destination "D:\ftp\" -Force
	    }
}
$filewatcher = New-Object System.IO.FileSystemWatcher
$filewatcher.Path = "D:\Change"
$filewatcher.IncludeSubdirectories = $true
$filewatcher.EnableRaisingEvents = $true
Register-ObjectEvent $filewatcher "created" -Action { checkFilestatus($($eventargs.fullpath))}
Register-ObjectEvent $filewatcher "Changed" -Action { checkFilestatus($($eventargs.fullpath))}
