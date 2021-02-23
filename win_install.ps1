#Requires -RunAsAdministrator

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

function LinkDotFile {
  Param (
    $ProfileLink,
    $Link,
    $DotFile
  )

  $ArgString = "ProfileLink=$ProfileLink Link=$Link DotFile=$DotFile"

  if (-Not $DotFile) { Throw "Target not specified $ArgString" }

  $Target = (Join-Path -Path $DotFilesRoot -ChildPath $DotFile)

  if (-Not (Test-Path -Path $Target)) { Throw "Target doesn't exist $ArgString" }

  if ($ProfileLink) {
    if ($Link) { Throw "Ambiguous link location. $ArgString" }
    $Link = (Join-Path -Path $env:USERPROFILE -ChildPath $ProfileLink)
  }

  SafeLink -Link $Link -Target $Target
}

function LinkXdgConfigFile {
  Param (
    $XDGConfigFile
  )

  if (-Not $XDGConfigFile) { Throw "XDGConfigFile not specified" }

  $Target = (Join-Path -Path $XDGConfigRoot -ChildPath $XDGConfigFile)

  if (-Not (Test-Path -Path $Target)) { Throw "Target $Target doesn't exist for $XDGConfigFile" }

  $XDGConfigHome = $env:XDG_CONFIG_HOME
  if (-Not $XDGConfigHome) {
    $XDGConfigHome = (Join-Path -Path "$env:USERPROFILE" -ChildPath ".config")
  }

  if (-Not (Test-Path -Path $XDGConfigHome)) {
    $NewDir = New-Item -Type Directory -Path $XDGConfigHome
    $NewDirAcl = $NewDir | Get-Acl
    $NewDirAcl.SetOwner([System.Security.Principal.WindowsIdentity]::GetCurrent().User)
    $NewDir | Set-Acl -AclObject $NewDirAcl
  }

  $Link = (Join-Path -Path $XDGConfigHome -ChildPath $XDGConfigFile)

  SafeLink -Link $Link -Target $Target
}

function SafeLink {
  Param(
    $Link,
    $Target
  )

  if (-Not $Link) { Throw "No link location." }

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
      Rename-Item -Path $Link -NewName "$Link.bak-$TimeStamp"
    }
  }

  New-Item -ItemType SymbolicLink -Path $Link -Value $Target
}

$DotFilesRoot = Join-Path -Path $Repo -ChildPath "dotfiles"
$XDGConfigRoot = Join-Path -Path $Repo -ChildPath "xdg_config"

$TimeStamp = (Get-Date -UFormat "%s").split(".")[0]

# Test linking before trying the real thing
$testfile = (Join-Path -Path $env:TEMP -ChildPath "deleteme-dotfiles-$TimeStamp.tmp")
try {
  LinkDotFile -Link $testfile -DotFile "vim/vimrc" | Out-Null
} catch { throw } finally {
  Remove-Item -Path $testfile -Force -ErrorAction SilentlyContinue
}

LinkDotFile -ProfileLink "_ackrc"     -DotFile "ackrc"
if (-Not $env:ACKRC -And $PSCmdlet.ShouldProcess("ACKRC", "Set env var")) {
  [System.Environment]::SetEnvironmentVariable(
    "ACKRC",
    (Join-Path -Path $env:USERPROFILE -ChildPath '_ackrc'),
    [System.EnvironmentVariableTarget]::User)
}

LinkDotFile -ProfileLink ".gitconfig" -DotFile "gitconfig"
LinkDotFile -ProfileLink "vimfiles"   -DotFile "vim"

LinkXdgConfigFile -XDGConfigFile "git"
