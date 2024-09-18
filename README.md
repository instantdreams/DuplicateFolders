# DuplicateFolders

A PowerShell script that will duplicate the content of one folder to another.

This script wraps Robocopy, the Robust File Copy program that is included with the Windows operating system.


## Features

The DuplicateFolders PowerShell script uses a configuration file to allow easy management of your personal settings plus the Robocopy preferences of your choice.

The DuplicateFolders PowerShell script will:

* Copy the content of one folder to another
* By default, mirror the structure and attributes of the files
* Write results to a log file for analysis
* Optionally notify a telegram channel with the result from the copy


## Prerequisites

To install the script on your system you will need the following information:

* A script location for your PowerShell scripts (e.g. "C:\Tools\Scripts" or "D:\ServerFolders\Company\Scripts")
* A folder for log files (e.g. "C:\Tools\Scripts\Logs" or "D:\ServerFolders\Company\Scripts\Logs")
* A working install of [robocopy](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/robocopy)


## Installation

A simple clone of the repository is all that is required:

* On the [GitHub page for this repository](https://github.com/instantdreams/DuplicateFolders) select "Clone or Download" and copy the web URL
* Open your git BBash of choice and enter the following commands:
	* cd {base location of your scripts folder} (e.g. /d/ServerFolders/Company/Scripts)
	* git clone {repository url} (e.g. https://github.com/instantdreams/DuplicateFolders.git)

This will install a copy of the scripts and files in the folder "DuplicateFolders" under your script location.


## Configuration

Minor configuration is required before running the script:

* Open File Explorer and navigate to your script location
* Copy file "DuplicateFolders-Sample.xml" and rename the result to "DuplicateFolders.xml"
* Edit the file with your favourite text or xml editor
	* For JobFolder enter the full path to the script folder (e.g. "C:\Tools\Scripts\DuplicateFolders")
	* For LogFolder enter the full path to the log folder (e.g. "C:\Tools\Scripts\Logs")
* Save the file and exit the editor

The following should be considered
* Files to Includes
  * Using *.* will include all files
  * If you wish to pick specific files, adjust this, e.g. "*.PDF"
* Files To Copy
  * /COPYALL : equivalent to /COPY:DATS
  * /COPY:DATS : Copy Data, Attributes, Timestamps, Security
  * /SECFIX : FIX file SECurity on all files, even skipped files.
* Copy Options
  * /E: copy subdirectories, including empty ones
  * /R: times to retry
  * /W: seconds to wait between retries
  * /V: print verbose output
  * /NP: don't show percentage copied (per file?)
  * /FP: include full pathname of files
  * /TEE: output to console and logfile
  * /ZB: first try copying files in restartable mode; if file busy or access denied try backup mode
  * /MT  : Multi-threaded copy
  * /FFT : assume FAT File Times
  * Not used:
    * /NFL : No File List - don't log file names.
    * /NDL : No Directory List - don't log directory names.
    * /L   : List only - don't copy, timestamp or delete any files.
The default settings use /ZB which will attempt to restart from point of failure. This can decrease performance and throughput, but are useful for overnight backups.

If calling using the -Notify option, include the following:

* TelegramToken
  * Your Telegram token from the BotFather
* TelegramChatId
  * Your Telegram Chat Id



## Running

To run the script, open a PowerShell window and use the following commands:
```
Set-Location -Path "D:\ServerFolders\Company\Scripts\DuplicateFolders"
Push-Location -Path "D:\ServerFolders\Company\Scripts\DuplicateFolders"
[Environment]::CurrentDirectory = $PWD
.\DuplicateFolders.ps1 -Source "D:\ServerFolders\Company\Temp\Source" -Destination "D:\ServerFolders\Company\Temp\Destination"
```

This will attempt to duplicate the folders from D:\ServerFolders\Company\Temp\Source to D:\ServerFolders\Company\Temp\Destination and create a log file with the standard name.


## Scheduling

This script was designed to run as a scheduled task to duplicate serverfolders from one hard drive to another as part of a nightly local backup routine. With Windows or Windows Server, the easiest way of doing this is to use Task Scheduler.

1. Start Task Scheduler
2. Select Task Scheduler Library
3. Right click and select Create Task
4. Use the following entries:
* General
  * Name:			DuplicateFolders-DH
  * Description:	Copy folders from D:\ServerFolders to H:\ServerFolders
  * Account:		Use your script execution account
  * Run whether user is logged on or not
  * Run with highest privileges
* Triggers
  * Daily
  * Start at:		02:00
  * Recur every:	1 day
  * Enable
* Actions
  * Action:			Start a program
  * Program:		PowerShell
  * Arguments:		-ExecutionPolicy Bypass -NoLogo -NonInteractive -File "{script location}\DuplicateFolders\DuplicateFolders.ps1" -Source "D:\ServerFolders" -Destination "H:\ServerFolders" -JobName "DuplicateFolders-DH"
  * Start in:	{script location}\DuplicateFolders
* Settings
  * Allow task to be run on demand
  * Stop the task if it runs longer than: 1 day

Adjust the arguments as needed to backup your drives to their hot standby. It is good practice to separate each job by an hour, but review the logs and tweak to your needs.


## Troubleshooting

Please review the log files located in the log folder to determine any issues.


## Author

* **Dean W. Smith** - *Script Creation* - [instantdreams](https://github.com/instantdreams)


## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details


## Security

This project has a security policy - see the [SECURITY.md](SECURITY.md) file for details