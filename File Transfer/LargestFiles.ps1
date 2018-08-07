function Get-BigFiles
    ($dir = "C:\",
     $num = 10)
{
    Get-ChildItem -path $dir -recurse |
    where{$_.Attributes -notlike "*Directory*"} |
    Sort-Object -property length -descending |
    Select-Object -first $num -property name,length }