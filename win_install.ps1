[CmdletBinding(SupportsShouldProcess = $True, DefaultParameterSetName="None")]
Param (
  [Parameter(Mandatory=$True,Position=1,ParameterSetName="RepoPath")]
  [ValidateNotNullOrEmpty()]
  [string]
  $Repo = (Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent),

  [switch]
  $Overwrite = $False
)

$ErrorActionPreference = "Stop";

$DotFilesRoot = Join-Path -Path $Repo -ChildPath "dotfiles"
$XDGConfigRoot = Join-Path -Path $Repo -ChildPath "xdg_config"
$TimeStamp = (Get-Date -UFormat "%s").split(".")[0]
$BackupDir = Join-Path -Path "$env:USERPROFILE" -ChildPath "dotfiles-backups-$TimeStamp"
$XdgBackupDir = Join-Path -Path $BackupDir -ChildPath "xdg_config_backups"

$XdgConfigHome = $env:XDG_CONFIG_HOME
if (-Not $XdgConfigHome) {
  $XdgConfigHome = Join-Path -Path $env:USERPROFILE -ChildPath ".config"
}

if (-Not ($XdgConfigHome) -Or -Not (Test-Path -Path $XdgConfigHome -Type Container)) {
  Throw "XDG_CONFIG_HOME path `"$XDG_CONFIG_HOME`" is not a directory"
}

New-Item -Type Directory -Path $BackupDir | Out-Null
New-Item -Type Directory -Path $XdgBackupDir | Out-Null


function SafeLink {
  Param(
    $Link,
    $Target,
    $BackupDest = $BackupDir
  )

  Write-Verbose "Attempting to link $Link->$Target (Backup to $BackupDest)"

  if (-Not $Link -Or -Not $Target) { Throw "Invalid arguments" }

  if (Test-Path -Path $Link) {
    if ($Overwrite) {
      if (Test-Path $Link -PathType Container) {
        if ($PSCmdlet.ShouldProcess($Link, "delete")) {
          [IO.Directory]::Delete($Link)
        }
      } else {
        Remove-Item -Path $Link -Confirm:$False
      }
    } else {
      Move-Item -Path $Link -Destination $BackupDest
    }
  }

  New-Item -Type Junction -Path $Link -Value $Target | Out-Null
}

function LinkProfileDir {
  Param($ProfileDirName, $DotFileDirName)
  if (-Not $ProfileDirName -Or -Not $DotFileDirName) { Throw "Invalid arguments" }
  SafeLink -Link (Join-Path -Path $env:USERPROFILE -ChildPath $ProfileDirName) -Target (Join-Path -Path $DotFilesRoot -ChildPath $DotFileDirName)
}

function LinkXDGConfigDir {
  Param($XdgDirName)
  if (-Not $XdgDirName) { Throw "Invalid arguments" }
  SafeLink -Link (Join-Path -Path $XdgConfigHome -ChildPath $XdgDirName) -Target (Join-Path -Path $XdgConfigRoot -ChildPath $XdgDirName) -BackupDest $XdgBackupDir
}

# Test linking before trying the real thing
$testfile = (Join-Path -Path $env:TEMP -ChildPath "deleteme-dotfiles-$TimeStamp.tmp")
try {
  SafeLink -Link $testfile -Target $XdgBackupDir
} catch { throw } finally {
  [IO.Directory]::Delete($testFile)
}

$UserEnvVars = @{
  'ACKRC'=(Join-Path -Path $DotFilesRoot -ChildPath 'ackrc')
}

$UserEnvVars.Keys | ForEach-Object {
  $OldVar = "$_=$([System.Environment]::GetEnvironmentVariable($_, [System.EnvironmentVariableTarget]::User))"

  Write-Verbose "Found old env: $OldVar"
  $OldVar | Out-File -Append -FilePath (Join-Path -Path $BackupDir -ChildPath 'UserEnvVars.txt')

  Write-Verbose "Setting new env: $_=$($UserEnvVars[$_])"
  [System.Environment]::SetEnvironmentVariable($_, $UserEnvVars[$_], [System.EnvironmentVariableTarget]::User)
}

LinkXdgConfigDir -XdgDirName "git"
LinkProfileDir -ProfileDirName "vimfiles" -DotFileDirName "vim"

