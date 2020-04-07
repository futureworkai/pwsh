#https://sevenzip.osdn.jp/chm/cmdline/switches/method.htm
$initScript = {
    param ($compressor)
    $compressor.CustomParameters.Add("x", "9") # Super .ZIP Compression Default is 5
}

#Compress-7Zip -Path . -ArchiveFileName demo.7z -CustomInitialization $initScript

#https://www.powershellgallery.com/packages/7Zip4Powershell/1.9.0
#if (-not (Get-Command Expand-7Zip -ErrorAction Ignore)) {
#    Install-Package -Scope CurrentUser -Force 7Zip4PowerShell > $null
#}

#https://github.com/thoemmi/7Zip4Powershell

# Get-ChildItem -File | For-EachObject {  
#     Write-Output 'Name->' + $_.FullBame + 'BaseName->' + $_.BaseName
# }
#([io.fileinfo]"c:\temp\myfile.txt").basename

#https://superuser.com/questions/318197/how-do-i-get-get-childitem-to-filter-on-multiple-file-types
#$PARENT_FOLDER = "C:\OpenShare\_OutSystems.Learn\"
$PARENT_FOLDER = "C:\OpenShare\"

$files = @(Get-ChildItem -Path $PARENT_FOLDER -include ('*.7z', '*.zip') -Recurse -File -Name) # Recursive
#$files = @(Get-ChildItem -Path $PARENT_FOLDER -File -Name) # Works for Single Top Level Folder
foreach ($file in $files) {
    $BaseFileName = (Get-Item $PARENT_FOLDER$file).Basename
    $TARGET_FOLDER = $PARENT_FOLDER+$BaseFileName
    #Write-Output $TARGET_FOLDER 
    #New-Item $PARENT_FOLDER+$BaseFileName -ItemType directory
    Expand-7Zip -ArchiveFileName $PARENT_FOLDER$file -TargetPath $TARGET_FOLDER # Added Extra Folder Path by Force
    #Expand-7Zip -ArchiveFileName $PARENT_FOLDER$file -TargetPath $TARGET_FOLDER # Added Extra Folder Path by Force
    # Now Check all Files Are Present and then Delete Original .ZIP File
    $ArchiveManifest = Get-7Zip -ArchiveFileName $PARENT_FOLDER$file | Select-Object FileName,CRC,IsDirectory
    #$ArchiveManifest | Get-Member
    # Get the Shortest Folder Path from the IsDirectory = Yes
    #C:\OpenShare\HashMyFiles.exe /folder "C:\OpenShare\lanbench_v1.1.0" /scomma "C:\OpenShare\Manifest.CSV"
    $ARGUMENTS = " /folder $TARGET_FOLDER /scomma "+'"C:\OpenShare\Manifest.CSV"'
    #Write-Output $ARGUMENTS
    Start-Process -Wait -FilePath "C:\OpenShare\HashMyFiles.exe" -ArgumentList $ARGUMENTS
    #https://adamtheautomator.com/powershell-import-csv-foreach/
    $CSV_CRC32 = Import-Csv -Path "C:\OpenShare\Manifest.CSV"
    $FileNames = @()
    $Checksums = @()
    ForEach ($entry in $CSV_CRC32){
        $filename = $($entry.Filename)
        #$fullpath = $($entry."Full Path")
        #$folderpath = $fullpath.Replace($filename,"")
        #$filesize = $($entry."File Size")
        $CRC32 = $($entry.CRC32)
        $FileNames += $filename
        $Checksums += $CRC32
        #Write-Output $fullpath $filename $filesize $CRC32
        #$summary = $filename+','+$CRC32
        #Write-Output $summary
        #if ($ArchiveManifest.
    }
    # Write-Host $Checksums.Length
    # Write-Host $FileNames.Length
    $OnlyCRC = $ArchiveManifest | Select-Object -ExpandProperty CRC
    # Write-Host $OnlyCRC.Length
    $boolFileMissingOrCorrupt = $false 
    #https://stackoverflow.com/questions/27690918/array-find-and-indexof-for-multiple-elements-that-are-exactly-the-same-object
    foreach ($FileCRC in $OnlyCRC){
        if ($Checksums -contains $FileCRC){
            #https://devblogs.microsoft.com/scripting/find-the-index-number-of-a-value-in-a-powershell-array/
            #$Where = [array]::IndexOf($Checksums, $FileCRC)
            for($i=0;$i-le $Checksums.length-1;$i++){
                if ($FileCRC -eq $Checksums[$i]){
                    $Where = $i
                } 
            }
            Write-Host "$FileCRC->FileName: " $FileNames[$Where]
        } else {
            # for($i=0;$i-le $Checksums.length-1;$i++){
            #     if ($FileCRC -eq $Checksums[$i]){
            #         $Where = $i
            #     } 
            # }
            # Write-Warning "$FileCRC->FileName:$FileNames[$Where] in Archive MISSING from Extracted Folder!"
            Write-Warning "$FileCRC in Archive MISSING from Extracted Folder!"
            $boolFileMissingOrCorrupt = $true
        }
    }
    if ($boolFileMissingOrCorrupt) {
        Write-Warning "Manifest to Live Folder not a Match!"    
        Write-Output $ArchiveManifest
    } 
    #Write-Output $CSV_CRC32
    #Full Path,Filename,File Size,CRC32

    # $ExtractedFiles = @(Get-ChildItem -Path $PARENT_FOLDER -Recurse) # Needs to Be Files and Folders 
    # foreach ($extractedFile in $ExtractedFiles) {
    #     $Hash = Get-FileHash -Path $extractedFile.FullName -Algorithm CRC32
    #     Write-Output "$extractedFile CRC: $Hash"
    # }
}

#https://www.powershellmagazine.com/2015/05/12/natively-query-csv-files-using-sql-syntax-in-powershell/

<#
#https://community.idera.com/database-tools/powershell/ask_the_experts/f/learn_powershell_from_don_jones-24/21696/query-a-csv-file-using-powershell

$Newlist = Import-Csv C:\powershell\Servers.csv | Add-Member -MemberType noteproperty -Name Results -Value "success" -PassThru | Select-Object ActionID, Action, ServerName, PreCheckForActionID, Results
$verynew = $Newlist | Select-Object -Property ActionID, Results, PreCheckForActionID | Select-Object -Property ActionID,PreCheckForActionID 
foreach($item in $verynew){
 $item.PreCheckForActionID
}

#>

#Get-ChildItem -File | Expand-7Zip -ArchiveFileName '.\Aggregates 101 Exercise Materials.zip' -TargetPath ".\" + $_.BaseName

#https://stackoverflow.com/questions/12503871/removing-path-and-extension-from-filename-in-powershell

<#https://www.sans.org/blog/powershell-7-zip-module-versus-compress-archive-with-encryption/

Get-Command -Module 7Zip4PowerShell

4 Cmdlets

Get-7ZipInformation <= Top Level File Information Only

Compress-7Zip <= Make Archives

To copy all the *.log files in the present directory into a 7z-compressed archive:

Get-ChildItem *.log | Compress-7Zip -ArchiveFileName logbackup.7z

To copy the F:\Temp folder and all its subdirectories and files into a traditional Zip archive that is compatible with Windows, Mac and Linux:

Compress-7Zip -Path F:\Temp -ArchiveFileName backup.zip -Format Zip

To open an archive in the graphical 7-Zip application for viewing, just invoke or "execute" the archive's file name at the command line:
.\logbackup.7z
(Note: You can associate other archive file name extensions with 7-Zip by pulling down the Tools menu in 7-Zip and selecting Options.)
To see details about the files inside an archive without actually extracting them:

Get-7Zip <= Information Only and Pipeline Compatible.

Get-7Zip -ArchiveFileName logbackup.7z

Get-7Zip -ArchiveFileName archive.zip | Format-Table FileName,Size

Get-7Zip -ArchiveFileName '.\Aggregates 101 Exercise Materials.zip' | Format-Table FileName,Size,CreationTime

To extract everything from an archive into the present directory ("."):

Expand-7Zip -ArchiveFileName archive.zip -TargetPath .

(If you want to go beyond the above basic operations, see this command reference and the -CustomInitialization parameter. You have access to all the features of 7-Zip through the PowerShell wrapper, it's just that not all of them are exposed as separate parameter names — there would be far too many, it would be clutter for 99% of users.)

https://sevenzip.osdn.jp/chm/cmdline/switches/method.htm

To archive and encrypt a folder and everything underneath it with a passphrase:

Compress-7Zip -Path .\DataFolder -ArchiveFileName backup.7z -Format SevenZip -Password "BigBeautifulPassword" -EncryptFilenames

Notice in the above that the archive format is SevenZip (creates a *.7z file) and the -EncryptFilenames switch is used. 
As discussed above, this combination should be considered mandatory. If you do not encrypt file names, and you attempt 
to extract files from the encrypted 7z archive using the wrong password (perhaps accidentally) then you risk overwriting any existing files with the same names with empty files, thus deleting the contents of those files! This does not happen when the -EncryptFilenames switch is always used.

To decrypt and extract the files from a 7z archive to the C:\Data folder:

Expand-7Zip -ArchiveFileName backup.7z -Password "SomeLONG&randuumP@ssf8zzaize" -TargetPath C:\Data

In a PowerShell script, the passphrase and other arguments could be stored as variables:

$Key = "iLFH&s9a>P=e9AcaCh_TaGIni<pre>$Key = "iLFH&s9a>P=e9AcaCh_TaGIni#####replaceparse10#####gt;+e#^s=%#PZ2Vc1&~sM-PXT)Km{(REM?<LR^p~!"

Expand-7Zip -ArchiveFileName backup.7z -Password $Key -TargetPath C:\Data</pre>gt;+e#^s=%#PZ2Vc1&~sM-PXT)Km{(REM?<LR^p~!"

Expand-7Zip -ArchiveFileName backup.7z -Password $Key -TargetPath C:\Data

But we don't want to hard-code decryption keys into scripts, so how could we safely get the key string into the variable? And if the key string is 50+ random characters, it's just too long to enter by hand each time.

KeePass for 7-Zip and PowerShell
The 7-Zip encryption passphrase can be over 1000 characters in length. This is too long for a human to enter by hand, but a 50-character passphrase might be stored in a password manager application, like KeePass.

Because KeePass can also be scripted with PowerShell, this opens up new possibilities in which KeePass secures a passphrase for 7-Zip, 7-Zip encrypts gigabytes of sensitive data, and PowerShell provides the automation to glue it all together.

(Here is another KeePass module for PowerShell in GitHub, soon to be in the PSGallery too.)

For example, you could encrypt 500GB of your personal files using 7-Zip and an encryption passphrase stored in KeePass, then upload that archive to Amazon Glacier or Azure Cool Blob Storage for pennies per month. Because your data is encrypted locally, you don't have to trust Amazon or Microsoft. Because you're using PowerShell to automate the process, it can be done quickly and conveniently. And because the encryption passphrase is stored in KeePass, the passphrase does not need to be hard-coded into any plaintext scripts.

(When archiving a large number of data files, it may be best to first make copies of those files to a temp folder, archive the copies from the temp folder, then securely delete the temp folder. Using the built-in ROBOCOPY.EXE utility you can copy just the files you want to archive using a variety of command-line switches. On Server 2016 and later, check out Storage Replica vs. ROBOCOPY too.)

In summary, when encrypting small chunks of data, like credit card numbers and passphrases, KeePass can be scripted with PowerShell. When encrypting gigabytes of data, 7-Zip can be scripted with PowerShell too. Combining these tools and PowerShell together, we can automate the solution to many data encryption problems (for free). And because KeePass and 7-Zip are cross-platform, we can hopefully interoperate with Mac and Linux users too.
#>