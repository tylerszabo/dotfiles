[CmdletBinding(DefaultParameterSetName="None")]
Param (
    [Parameter(Mandatory=$True,Position=1,ParameterSetName="RepoPath")]
    [ValidateNotNullOrEmpty()]
    [string]
    $Repo = (Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent),

    [switch]
    $Overwrite = $False,

    [switch]
    $WhatIf = $False
)

$DotFilesRoot = Join-Path -Path $Repo -ChildPath "dotfiles"

$TimeStamp = (Get-Date -UFormat "%s").split(".")[0]

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

    if (-Not $Link) { Throw "No link location. $ArgString" }

    if (Test-Path -Path $Link) {
        if ($Overwrite) {
            if (Test-Path $Link -PathType Container) {
                if ($WhatIf) { "WhatIf: Would delete $Link" } else {
                    [IO.Directory]::Delete($Link)
                }
            } else {
                Remove-Item -Path $Link -Confirm:$False -WhatIf:$WhatIf
            }
        } else {
            Move-Item -Path $Link -Destination "$Link-$TimeStamp" -WhatIf:$WhatIf
        }
    }

    if ($WhatIf) { Write-Host "WhatIf: Would create link: $Link -> $Target" } else {
        New-Item -ItemType SymbolicLink -Path $Link -Value $Target
    }
}

LinkDotFile -ProfileLink "_ackrc"       -DotFile "ackrc"
LinkDotFile -ProfileLink ".gitconfig"   -DotFile "gitconfig"
LinkDotFile -ProfileLink "_vimrc"       -DotFile "vimrc"
LinkDotFile -ProfileLink "vimfiles"     -DotFile "vim"