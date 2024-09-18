## ---- [Script Parameters] ----
Param
(
    [Parameter(Mandatory=$True)] [string] $Source,
    [Parameter(Mandatory=$True)] [string] $Destination,
    [Parameter(Mandatory=$False)] [Switch] $Notify,
    [Parameter(Mandatory=$False)] [string] $JobName
)


# Function Copy-Folders - copy the source folder to the destination folder
function Copy-Folders
{
    <#
    .SYNOPSIS
        Copy contents of one folder to another
    .DESCRIPTION
        Use Robocopy to duplicate a folder
    .EXAMPLE
        Copy-Folders
    .OUTPUTS
        None
    .NOTES
        Version:        1.0
        Author:         Dean Smith | deanwsmith@outlook.com
        Creation Date:  2018-02-18
        Purpose/Change: Initial script creation
        Version:        1.1
        Author:         Dean Smith | deanwsmith@outlook.com
        Update Date:    2019-07-03
        Purpose/Change: Merged scripts to use functions
        Version:        1.2
        Author:         Dean Smith | deanwsmith@outlook.com
        Update Date:    2024-09-17
        Purpose/Change: Updated to use global variable for notification
    #>
    ## ---- [Function Parameters] ----
    [CmdletBinding()]
    Param()

    ## ---- [Function Beginning] ---    -
    Begin {}

    ## ---- [Function Execution] ----
    Process
    {
        # Set up arguments for Robocopy
        $DuplicateArguments = "`"$Source`" `"$Destination`" $FilesToInclude $FilesToCopy /LOG+:`"$LogFile`" $CopyOptions"
        $TimeStamp = Get-Date -uformat "%T"
        $LogMessage = ("`r`n$TimeStamp`t${JobName}`nCommand:`t$FileHandler`nArguments:`t$DuplicateArguments")
        Add-Content $LogFile $LogMessage -PassThru

        # Call Robocopy to duplicate folders
        $Robocopy = Start-Process -FilePath $FileHandler -WorkingDirectory $JobFolder -ArgumentList $DuplicateArguments -NoNewWindow -PassThru -Wait

        # Work out what the exit code was
        $TimeStamp = Get-Date -uformat "%T"
        $LogMessage = ("`r`n$TimeStamp`t${JobName}`tDuplicate-Folders")
        $LogMessage = $LogMessage + ("`nRobocopy finished with exit code: " + $Robocopy.ExitCode)
        $ExitMessage = @{
            16 = "[Error] Serious error. Robocopy did not copy any files. Examine the output log: $LogFile"
            15 = "OKCOPY + FAIL + MISMATCHES + XTRA"
            14 = "FAIL + MISMATCHES + XTRA"
            13 = "OKCOPY + FAIL + MISMATCHES"
            12 = "FAIL + MISMATCHES"
            11 = "OKCOPY + FAIL + XTRA"
            10 = "FAIL + XTRA"
            9 = "OKCOPY + FAIL"
            8 = "[Error] Some files or directories could not be copied (copy errors occurred and the retry limit was exceeded). Check these errors further: $LogFile"
            7 = "OKCOPY + MISMATCHES + XTR"
            6 = "MISMATCHES + XTRA"
            5 = "OKCOPY + MISMATCHES"
            4 = "[Warning] No errors, just a quick warning. Some Mismatched files or directories were detected. Examine the output log: $LogFile. Housekeeping is probably necessary."
            3 = "OKCOPY + XTRA"
            2 = "[Info] No errors. Some Extra files or directories were detected and may have been removed (if /MIR used) from $Destination. Check the output log for details: $LogFile"
            1 = "[Info] No errors. New files from $Source copied to $Destination successfully. Check the output log for details: $LogFile"
            0 = "[Info] No errors. $Source and $Destination in sync. No files copied. Check the output log for details: $LogFile"
        }
        # check if this error code exists in the hash
        If ($ExitMessage.ContainsKey($Robocopy.ExitCode)) { $LogMessage = $LogMessage + "`n" + $ExitMessage.($Robocopy.ExitCode) }
        Else { $LogMessage = $LogMessage +  "`n[Unknown] Can't interpret this exit code." }
        Add-Content $LogFile $LogMessage -PassThru
        If ($Notify) { $global:TelegramMessage = ("Job: " + $JobName + "`nMessage: " + $ExitMessage.($Robocopy.ExitCode)) }
    }

    ## ---- [Function End] ----
    End {}
}


# Function Send-Telegram - send a message to a telegram chat or channel
Function Send-Telegram
{
    <#
    .SYNOPSIS
        Send a notification to Telegram
    .DESCRIPTION
        Using a Token and ChatId, send a notification
    .EXAMPLE
        Send-Telegram
    .OUTPUTS
        None
    .NOTES
        Version:        1.0
        Author:         Dean Smith | deanwsmith@outlook.com
        Creation Date:  2024-09017
        Purpose/Change: Initial script creation
    #>
    ## ---- [Function Parameters] ----
    [CmdletBinding()]
    Param()

    ## ---- [Function Beginning] ----
    Begin {}

    ## ---- [Function Execution] ----
    Process
    {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $Response = Invoke-RestMethod -Uri "https://api.telegram.org/bot$($TelegramToken)/sendMessage?chat_id=$($TelegramChatId)&text=$($global:TelegramMessage)"
    }

    ## ---- [Function End] ----
    End {}
}


<#
.SYNOPSIS
    Duplicate folder from one location to another
.DESCRIPTION
    Call Robocopy to backup folder structure from one location to another
.EXAMPLE
    .\DuplicateFolders.ps1 -Source "D:\ServerFolders" -Destination "H:\ServerFolders" -JobName "DuplicateFolders-DH"
    .\DuplicateFolders.ps1 -Source "E:\ServerFolders" -Destination "I:\ServerFolders"
.PARAMETER Source
    Source directory. Spaces and UNC pathnames (\\server\share...) allowed. Do not include a trailing backslash.
.PARAMETER Destination
    Destination directory. Spaces and UNC pathnames (\\server\share...) allowed. Do not include a trailing backslash.
.PARAMETER JobName
    Job Name for log file purposes if you would like to include an indicator of what has been copied, e.g. DuplicateFolders-DH
.OUTPUTS
    Log file
.NOTES
    Version:        1.0
    Author:         Dean Smith | deanwsmith@outlook.com
    Creation Date:  2018-02-18
    Purpose/Change: Initial script creation
    Version:        1.1
    Author:         Dean Smith | deanwsmith@outlook.com
    Update Date:    2019-07-03
    Purpose/Change: Merged scripts to use functions
#>

## ---- [Execution] ----

# Load configuration details and set up job and log details
$ConfigurationFile = ".\DuplicateFolders.xml"
If (Test-Path $ConfigurationFile)
{
	Try
	{
        $Job = New-Object xml
        $Job.Load("$ConfigurationFile")
		$JobFolder = $Job.Configuration.JobFolder
        If (-Not $JobName) { $JobName = $Job.Configuration.JobName }
		$LogFolder = $Job.Configuration.LogFolder
        $JobDate = Get-Date -Format FileDateTime
        $LogFile = "$LogFolder\${JobName}-$JobDate.log"
        $FileHandler = $Job.Configuration.FileHandler
        $FilesToInclude = $Job.Configuration.FilesToInclude
        $FilesToCopy = $Job.Configuration.FilesToCopy
        $CopyOptions = $Job.Configuration.CopyOptions
        $TelegramToken = $Job.Configuration.TelegramToken
        $TelegramChatId = $Job.Configuration.TelegramChatId
	}
	Catch [system.exception]
    {
        Add-Content $LogFile "Caught Exception: $($Error[0].Exception.Message)" -PassThru
    }
}

# Start Transcript - We normally would use a transcript but we'll instead add to the logfile that Robocopy uses
#Start-Transcript -Path $Logfile -NoClobber -Verbose -IncludeInvocationHeader
$Timestamp = Get-Date -UFormat "%T"
$LogMessage = ("-" * 79 + "`r`n$Timestamp`t${JobName}: Starting Transcript`r`n" + "-" * 79)
Add-Content $LogFile $LogMessage -PassThru

# Call functions to copy folders
If ($Notify) { $global:TelegramMessage = $null }
Copy-Folders
If ($Notify) { Send-Telegram }

## Stop Transcript
$Timestamp = Get-Date -UFormat "%T"
$LogMessage = ("`r`n" + "-" * 79 + "`r`n$Timestamp`t${JobName}: Stopping Transcript`r`n" + "-" * 79)
Add-Content $LogFile $LogMessage -PassThru
#Stop-Transcript
