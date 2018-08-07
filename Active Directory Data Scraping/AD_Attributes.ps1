


$erroractionpreference = “SilentlyContinue”



# Import AD Module
Import-Module ActiveDirectory

#Get Root DSE Domain
$DomainInfo = [System.DirectoryServices.DirectoryEntry] "LDAP://RootDSE"

#Set Ouput Path 
$path="c:\LogFileUserAttributeChange_" + (Get-Date -Format "MM-dd-yyyy_HH:mm:ss") + $DomainInfo.DefaultNamingContext + "_" + ".csv"

"User Sam ID `t Job Title `t Manager `r`n" | Out-File $path -Append 

# Import CSV into variable $userscsv

$userscsv = import-csv "c:\UserAttribute.csv"

# Loop through CSV and update users if they exist in CVS file

foreach ($user in $userscsv) {
Set-ADUser -Identity $user.name -Title $user.JobTitle -Manager $user.Manager  
     $JobTitle = $user.JobTitle 
	 $Manager = $user.Manager 
 
if ($error[0] -eq $null){
       $user.Name + "`t" + "Successfully Changed JobTitle to $JobTitle" + "`t" + "Successfully Changed Manager to $manager" | Out-File $path -Append 
                        }
	  else{
	   $user.Name + "`t" + "Failed to Change Attribute" + "`t" + "Failed to Change Attribute" | Out-File $path -Append
          }      
		  $error.clear()

		                     }



$erroractionpreference = “SilentlyContinue”

# Import AD Module
Import-Module ActiveDirectory

#Get Root DSE Domain
$DomainInfo = [System.DirectoryServices.DirectoryEntry] "LDAP://RootDSE"

#Set Ouput Path 
$path="c:\LogFileUserAttributeChange_" + (Get-Date -Format "MM-dd-yyyy_HH:mm:ss") + $DomainInfo.DefaultNamingContext + "_" + ".csv"

"User Sam ID `t EmployeeID `t Results `r`n" | Out-File $path -Append 

# Import CSV into variable $userscsv

$userscsv = import-csv "c:\UserAttribute.csv"

# Loop through CSV and update users if they exist in CVS file

foreach ($user in $userscsv) {
Set-ADUser -Identity $user.name -EmployeeID $user.employeeid  
    $name =  $user.name
    $employeeID = $user.employeeid
      
if ($error[0] -eq $null){
       $user.Name + "`t" + "Successfully Changed Attribute $name" + "`t" + "Successfully Changed Attribute EmployeeID to $employeeID" | Out-File $path -Append 
                        }
	  else{
	   $user.Name + "`t" + "Failed to Change Attribute $name" + "`t" + "Failed to Change Attribute EmployeeID to $employeeID" | Out-File $path -Append
          }      
		  $error.clear()

		                     }

