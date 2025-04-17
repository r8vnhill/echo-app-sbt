<#
.SYNOPSIS
Generates a filesystem path from an array of package segments.

.DESCRIPTION
The `Get-PackagePath` function constructs a nested directory path by joining an array of strings
(e.g., package or namespace components) using `Join-Path`.

This is particularly useful when translating a logical package name like
`com.github.username.echo` into a directory structure such as:
`com/github/username/echo`.

This function is intended for use within script scope (e.g., script modules or helper scripts).

.PARAMETER PackageParts
An array of strings representing the segments of the package or directory path.

.EXAMPLE
PS> Get-PackagePath -PackageParts @('com', 'github', 'username')

Returns:
com\github\username

.EXAMPLE
PS> Script:Get-PackagePath @('src', 'main', 'scala', 'org', 'example')

Returns:
src\main\scala\org\example

.RETURNS
[string] The resulting joined path as a string.

.NOTES
- This function does not create the directory on disk, it only returns the string path.
- Respects platform-specific path separators.
#>
function Script:Get-PackagePath([string[]]$PackageParts) {
    $path = $PackageParts[0]
    for ($i = 1; $i -lt $PackageParts.Count; $i++) {
        $path = Join-Path $path $PackageParts[$i]
    }
    return $path
}

<#
.SYNOPSIS
Creates a new directory for a Scala project component if it doesn't already exist.

.DESCRIPTION
The `New-ScalaDirectory` function is a script-scoped helper used to safely create a directory with
optional confirmation and `-WhatIf` support.

It wraps `New-Item` with `ShouldProcess` so it can participate in standard PowerShell deployment
workflows. It's intended for use in project scaffolding scripts (e.g., for creating `src`, `app`, or
`lib` folder structures).

.PARAMETER Path
The full path to the directory to create.

.PARAMETER Description
A friendly label for the directory (used in confirmation messages).
This value is included in the `ShouldProcess` prompt.

.EXAMPLE
PS> New-ScalaDirectory -Path "src/main/scala" -Description "Scala source root"

Creates the specified directory if it doesn't exist.

.EXAMPLE
PS> New-ScalaDirectory -Path "app/src/main/scala/org/example" -Description "App module" -WhatIf

Simulates the creation of the directory without making changes.

.NOTES
- Respects `-WhatIf` and `-Confirm` via `SupportsShouldProcess`.
- This function does not return a value.
- Designed to be used internally within a script or module.
#>
function Script:New-ScalaDirectory {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$Path,
        [string]$Description
    )
    if ($PSCmdlet.ShouldProcess($Path, "Create $Description directory")) {
        New-Item -Path $Path -ItemType Directory -Force -Confirm:$false | Out-Null
    }
}

<#
.SYNOPSIS
Creates a new Scala source file at the specified path.

.DESCRIPTION
The `New-ScalaFile` function is a script-scoped utility used to generate an empty `.scala` file
at a specified location.
It supports `-WhatIf` and `-Confirm` through `ShouldProcess`, allowing safe and reversible use in
project scaffolding scripts.

If the file already exists, it will be overwritten silently unless prevented by `-WhatIf` or
`-Confirm`.

.PARAMETER Path
The full file path where the Scala source file should be created.

.PARAMETER FileName
A label used in logging and `ShouldProcess` prompts (for user-friendly output and confirmation).

.EXAMPLE
PS> New-ScalaFile -Path "app/src/main/scala/org/example/App.scala" -FileName "App.scala"

Creates an empty Scala file at the specified path with confirmation support.

.EXAMPLE
PS> New-ScalaFile -Path "lib/src/main/scala/org/example/AppModule.scala" -FileName "AppModule.scala" -WhatIf

Simulates file creation without performing any actual changes.

.NOTES
- Designed for internal use in scaffolding tools.
- Writes verbose output when the file is successfully created.
- Does not return a value.
#>
function Script:New-ScalaFile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string]$Path,
        [string]$FileName
    )
    if ($PSCmdlet.ShouldProcess($Path, "Create $FileName file")) {
        New-Item -Path $Path -ItemType File -Force -Confirm:$false | Out-Null
        Write-Verbose "Created $FileName"
    }
}

<#
.SYNOPSIS
Initializes a modular Scala project structure with separate app and library packages.

.DESCRIPTION
The `Initialize-ScalaModules` function generates a consistent directory and file layout for a Scala
application.
It supports customization of the base package, app and lib subpackages, and file names for each
module.
It is especially useful in scaffolding workflows for structured Scala projects that separate
application and reusable logic.

Each step (directory and file creation) is wrapped with `ShouldProcess`, allowing full support
for `-WhatIf` and `-Confirm`.

.PARAMETER BasePackage
The base namespace for both app and lib modules, typically something like `com.github.username`.
Used to construct the shared `src/main/scala/...` path.

.PARAMETER AppPackage
The subpackage for the application module (default: `app`). Appends to the base path.

.PARAMETER LibPackage
The subpackage for the library module (default: `lib`). Appends to the base path.

.PARAMETER AppFileName
The Scala source file to create under the app module directory (default: `App.scala`).

.PARAMETER LibFileName
The Scala source file to create under the lib module directory (default: `Lib.scala`).

.EXAMPLE
PS> Initialize-ScalaModules

Creates:
  - app/src/main/scala/com/github/username/app/App.scala
  - lib/src/main/scala/com/github/username/lib/Lib.scala

.EXAMPLE
PS> Initialize-ScalaModules -BasePackage @('org', 'example') `
                            -AppFileName 'Main.scala' `
                            -LibFileName 'Utils.scala'

Creates:
  - app/src/main/scala/org/example/app/Main.scala
  - lib/src/main/scala/org/example/lib/Utils.scala

.EXAMPLE
PS> Initialize-ScalaModules -WhatIf

Simulates all steps (folder and file creation) without making changes.

.EXAMPLE
PS> Initialize-ScalaModules -Confirm

Prompts for confirmation before each action (creating a directory or file).

.NOTES
- This function depends on the helper functions: `Get-PackagePath`, `New-ScalaDirectory`, and
  `New-ScalaFile`.
- It is intended for use in structured builds or project generation workflows.
- All actions respect `-WhatIf` and `-Confirm`.

.OUTPUTS
None. Side effects include creation of directories and files.
#>
function Initialize-ScalaModules {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [string[]]$BasePackage   = @('com','github','username'),
        [string[]]$AppPackage    = @('app'),
        [string[]]$LibPackage    = @('lib'),
        [string]  $AppFileName   = 'App.scala',
        [string]  $LibFileName   = 'Lib.scala'
    )

    # calculamos rutas
    $basePath = Get-PackagePath -PackageParts (@('src','main','scala') + $BasePackage)
    $appPath  = Join-Path 'app' (Join-Path $basePath (Get-PackagePath -PackageParts $AppPackage))
    $libPath  = Join-Path 'lib' (Join-Path $basePath (Get-PackagePath -PackageParts $LibPackage))

    $appFile  = Join-Path $appPath $AppFileName
    $libFile  = Join-Path $libPath $LibFileName

    Write-Verbose "App directory: $appPath"
    Write-Verbose "Lib directory: $libPath"
    Write-Verbose "App file:      $appFile"
    Write-Verbose "Lib file:      $libFile"

    # aquí sí se evalúa ShouldProcess por cada paso
    New-ScalaDirectory -Path $appPath -Description 'app'
    New-ScalaDirectory -Path $libPath -Description 'lib'
    New-ScalaFile      -Path $appFile -FileName    $AppFileName
    New-ScalaFile      -Path $libFile -FileName    $LibFileName
}
