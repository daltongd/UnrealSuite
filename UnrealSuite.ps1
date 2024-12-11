<#PSScriptInfo
.VERSION 1.0
.GUID 4d1cc82a-972b-473b-88c2-569bf68c22c2
.AUTHOR dalton
.COPYRIGHT (c) 2024 Krzysztof Pachulski
.TAGS UnrealEngine, Unreal, UnrealSuite, RunUAT, UnrealBuildTool, UBT, BuildGraph, UnrealPak
.PROJECTURI https://gist.github.com/daltondotgd/e73d8748cb7a8f35243a3f69318519f9
#>

# Commenting it out for now, as I prefer a custom, more verbose information (see under the Param() block)
# so that the users can use the download link.
# #Requires -Version 7

<#

.SYNOPSIS
The script is built around independently running different steps of the Unreal Engine
build pipeline, but also allows for executing common Unreal binaries with arguments.

It's main power is that it automatically finds the project file, as well as the associated
Engine's path.

.DESCRIPTION
The UnrealSuite.ps1 script allows user to independently run different
steps of the Unreal Engine build pipeline and call RunUAT.exe, UnrealBuildTool.exe,
and the UnrealEditor-CMD.exe or UnrealEditor.exe with a capability to automatically
determine the associated Engine path, project's path and name as well as enabling
some other tricks for simplifying the workflow and shortening the commands.

The script supports presets for -RunUAT, -RunUBT and -RunEditor. They are slightly
odd at the moment, but should simplify performing common actions.

.PARAMETER ProjectName
Name of the Unreal Engine project (without the '.uproject'. extension).
Default:
    [AUTO] This parameter can be automatically determined based on the .uproject
    if the script is called from the project directory.

.PARAMETER ProjectPath
Path to project directory.
Default:
    [AUTO] This parameter can be automatically determined based on the .uproject
    if the script is called from the project directory.

.PARAMETER EngineAssociation
The registry key paired with the location of the relevant Engine version.
Default:
    [AUTO] This parameter can be automatically determined based on the .uproject
    if the script is called from the project directory.

.PARAMETER EnginePath
Path to the engine version.
Default:
    [AUTO] This parameter can be automatically determined based on the .uproject
    if the script is called from the project directory.

.PARAMETER StagingDirectory
Staging Directory location.
Default:
    [AUTO] This parameter can be automatically determined based on the .uproject
    if the script is called from the project directory.

    Defaults to:
        [$ProjectPath]\Saved\StagedBuilds


.PARAMETER ArchiveDirectory
Directory to place the packaged build in.
The game can be found under [$ArchiveDirectory]\[$ProjectName][$Configuration]
Default:
    [AUTO] This parameter can be automatically determined based on the .uproject
    if the script is called from the project directory.

    Defaults to:
        [$ProjectPath]\Build

.PARAMETER Platform
Platform to build for.
Default:
    Win64

.PARAMETER Configuration
Target Configuration (eg. Debug, Development, Test, Shipping).
Default:
    Development

.PARAMETER ReleaseVersionName
Version name for patching.
Default:
    Empty String

.PARAMETER ProjectFiles
Generates Visual Studio project files.

.PARAMETER Build
Builds both Editor and Game binaries in this order.

.PARAMETER BuildEditor
Builds Editor binaries.

.PARAMETER BuildGame
Builds Game binaries.

.PARAMETER Cook
Cooks the game content.

.PARAMETER Package
Packages the game.

.PARAMETER RunPackagedGame
Runs packaged game.

.PARAMETER All
Performs all above actions in the respective order.

.PARAMETER ContinueDespiteErrors
Prevents errors from stopping the build pipeline.

.PARAMETER Clean
Used with Build, BuildEditor or BuildGame. Clears intermediate files
before building.

.PARAMETER NoIterativeCooking
Disables iterative cooking. Use this for a clean cook.

.PARAMETER BuildGraph
BuildGraph is ran through UAT, but this is a handy helper option.
Exits immediately after execution.
Example:
    PS> .\UnrealSuite.ps1 -BuildGraph ".\Path\To\BuildGraphScript.xml" -CommandArgs "-set:Target='Editor'"

.PARAMETER PassProjectInfo
Used with BuildGraph and passes:
    -set:ProjectPath="$ProjectPath"
    -set:ProjectName="$ProjectName"
    -set:EngineAssociation="$EngineAssociation"
    -set:EnginePath="$EnginePath"
    -set:Platform="$Platform"
    -set:Configuration="$Configuration"
The values are automatically determined, but their values can be overriden.
Example:
    .\UnrealSuite.ps1 -BuildGraph ".\Path\To\BuildGraphScript.xml" -PassProjectInfo -CommandArgs "-set:Target='Game'"

.PARAMETER UnrealPak
Runs UnrealPak.exe. Will automatically look for the pak file with the name "$ProjectName(.*).pak" if the -PakFile
parameter is not provided.
Exits immediately after execution.
Examples:
    .\UnrealSuite.ps1 -UnrealPak -CommandArgs "-List"

.PARAMETER PakFile
Allows for providing a specific pak file for the UnrealPak.exe. Path can be relative to the project root or the script
location. Will look for common extensions "ucas", "utoc", and "pak" if the filename was not provided or provided without
extension. If project is using chunking it will only look for the "pakchunk0". Automatically finds only Windows pak files.
Exits immediately after execution.
Examples:
    .\UnrealSuite.ps1 -UnrealPak -PakFile "Path\To\PakFile.pak" -CommandArgs "-List"

.PARAMETER RunUAT
Runs RunUAT.bat with project and engine paths determined automatically
with provided arguments. Use -CommandArgs to provide arguments.
Exits immediately after execution.

.PARAMETER RunUBT
Runs UnrealBuildTool.exe with project and engine paths determined automatically
with provided arguments. Use -CommandArgs to provide arguments.
Exits immediately after execution.

.PARAMETER RunEditor
Runs UnrealEditor-CMD.exe with project and engine paths determined automatically
with provided arguments. Use -CommandArgs to provide arguments.
Exits immediately after execution.
Can be forced to use UnrealEditor.exe instead by using -NoCMD

.PARAMETER Map
Used with RunEditor. Will open the editor with the map specified. Required for
World Partition Commandlets.

.PARAMETER NoCMD
Used in pair with -RunEditor. It will make the command use UnrealEditor.exe
instead of UnrealEditor-CMD.exe

.PARAMETER CommandArgs
Used in pair with -BuildGraph, -UnrealPak, -RunUAT, -RunUBT, or -RunEditor.
Should contain arguments for the specified command.
Don't provide the project path in the argument list, use -ProjectPath
and -ProjectName parameters instead if you'd like to override the default behavior.
Example:
    .\UnrealSuite.ps1 -RunEditor -CommandArgs "-Game -FullScreen"

.PARAMETER Help
Used in pair with -RunUAT, -RunUBT and -UnrealPak. Displays help for the respective command.

.PARAMETER Preset
Used in pair with -RunUAT, -RunUBT, or -RunEditor. It will use a predefined preset.
You can apply extra arguments by using -CommandArgs parameter
Syntax:
    .\UnrealSuite.ps1 -RunXXXX -Preset "PresetName"

.PARAMETER List
Used with RunUAT. A shorthand for displaying all RunUAT commands.

.PARAMETER ListPresets
Lists all available presets.

.PARAMETER AdditionalBuildEditorParameters
Additional parameters for the BuildEditor command.

.PARAMETER AdditionalBuildGameParameters
Additional parameters for the BuildGame command.

.PARAMETER AdditionalCookParameters
Additional parameters for the Cook command.

.PARAMETER AdditionalPackageParameters
Additional parameters for the Package command.

.PARAMETER AdditionalRunPackagedGameParameters
Additional parameters for the Run Packaged Game command.
E.g. -WaitForDebugger might prove useful.

.INPUTS
None. You cannot pipe objects into UnrealSuite.ps1.

.OUTPUTS
None. The only outputs are generated by specific actions that are called by this script.

.EXAMPLE
.\UnrealSuite.ps1
Displays setup info.

.EXAMPLE
.\UnrealSuite.ps1 -All
Performs all build pipeline actions. The result is a packaged game in the [$ArchiveDirectory]\[$ProjectName][$Configuration]\ directory.

.EXAMPLE
.\UnrealSuite.ps1 -ProjectFiles -Build
Generate Visual Studio project files and compile the binaries for both Game and Editor configurations.

.EXAMPLE
.\UnrealSuite.ps1 -Cook
Cook the game content.

.EXAMPLE
.\UnrealSuite.ps1 -Cook -Package
Cook and Package the game. This is especially useful if you've already built the binaries, but want to test changes to the content.

.EXAMPLE
.\UnrealSuite.ps1 -BuildEditor
Builds the Editor binaries.

.EXAMPLE
.\UnrealSuite.ps1 -BuildGraph ".\Path\To\BuildGraphScript.xml" -CommandArgs "-set:Target='Editor'"
Run the BuildGraph with the supplied script.

.EXAMPLE
.\UnrealSuite.ps1 -BuildGraph ".\Path\To\BuildGraphScript.xml" -PassProjectInfo -CommandArgs "-set:Target='Game'"
Run the BuildGraph with the supplied script. Passes project info as parameters with generic names.
It makes an assumption about the parameter names, so it's likely you may have to pass them by hand if your script
uses different naming.

.EXAMPLE
.\UnrealSuite.ps1 -RunUAT -CommandArgs "BuildCookRun -Help"
Displays help for BuildCookRun commandlet
Docs: https://dev.epicgames.com/documentation/en-us/unreal-engine/build-operations-cooking-packaging-deploying-and-running-projects-in-unreal-engine?application_version=5.3

.EXAMPLE
.\UnrealSuite.ps1 -RunUBT -CommandArgs "-ProjectFiles -Game -Rocket -Progress"
Generates VS project files.

.EXAMPLE
.\UnrealSuite.ps1 -RunEditor -CommandArgs "-Game -FullScreen -Log=SpecificLogName.txt"
Run the game in fullscreen mode and log to a specific location.
Docs: https://dev.epicgames.com/documentation/en-us/unreal-engine/command-line-arguments-in-unreal-engine?application_version=5.3

.EXAMPLE
.\UnrealSuite.ps1 -RunEditor -Preset ResavePackages
Run the UnrealEditor-CMD.exe with a preset to resave editor packages.

.EXAMPLE
.\UnrealSuite.ps1 -UnrealPak -CommandArgs "-List"
Run UnrealPak and allows it to automatically find a pak file. List the pak file contents.

.EXAMPLE
.\UnrealSuite.ps1 -UnrealPak -PakFile "Path\To\PakFile.pak" -CommandArgs "-List"
Run UnrealPak on a specified pak file. List the pak file contents.

.NOTES
This script is especially useful for debugging the build pipeline. It allows to run the different steps
independently as separate commands, so you can inspect output of every stage, as well as try re-running
a specific step however many times you like, making changes in the meantime.

The script runs locally and it mimmics a behavior of a build server. You no longer have to make a commit
and block the buildserver whenever you're trying to fix an issue or work on a change in the configuration.

For example, when trying to deal with an issue causing the Cooking step to fail, one can adjust the content
and re-run only the Cooking step rather than waste time on going through the whole pipeline. This saves
a lot of time. Even if the subsequent builds finish rather quickly, if you end up repeating it many times
it adds up to a lot, as well as adds additional variables to the equation.

.LINK
https://dalton.gd/

#>

[CmdletBinding(
    SupportsShouldProcess,
    ConfirmImpact='Medium',
    DefaultParameterSetName='Default'
)]
param(
    [string]$ProjectName = '',
    [string]$ProjectPath = '',

    [string]$EngineAssociation = '',
    [string]$EnginePath = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$Platform = 'Win64',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$Configuration = 'Development',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$StagingDirectory = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$ArchiveDirectory = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$ReleaseVersionName = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$ProjectFiles,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$Build,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$BuildEditor,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$BuildGame,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$Cook,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$Package,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$All,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$RunPackagedGame,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$ContinueDespiteErrors,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$Clean,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [switch]$NoIterativeCooking,

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$AdditionalBuildGameParameters = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$AdditionalBuildEditorParameters = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$AdditionalCookParameters = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$AdditionalPackageParameters = '',

    [Parameter(ParameterSetName = 'BuildPipeline')]
    [string]$AdditionalRunPackagedGameParameters = '',

    [Parameter(ParameterSetName = 'BuildGraph')]
    [string]$BuildGraph = '',

    [Parameter(ParameterSetName = 'BuildGraph')]
    [switch]$PassProjectInfo,

    [Parameter(ParameterSetName = 'UnrealPak')]
    [switch]$UnrealPak,

    [Parameter(ParameterSetName = 'UnrealPak')]
    [string]$PakFile,

    [Parameter(ParameterSetName = 'Ushell')]
    [switch]$Ushell,

    [Parameter(ParameterSetName = 'RunUAT')]
    [switch]$RunUAT,

    [Parameter(ParameterSetName = 'RunUBT')]
    [switch]$RunUBT,

    [Parameter(ParameterSetName = 'RunEditor')]
    [switch]$RunEditor,

    [Parameter(ParameterSetName = 'RunEditor')]
    [string]$Map = '',

    [Parameter(ParameterSetName = 'RunEditor')]
    [switch]$NoCMD,

    [Parameter(ParameterSetName = 'BuildGraph')]
    [Parameter(ParameterSetName = 'UnrealPak')]
    [Parameter(ParameterSetName = 'RunUAT')]
    [Parameter(ParameterSetName = 'RunUBT')]
    [Parameter(ParameterSetName = 'RunEditor')]
    [string]$CommandArgs = '',

    [Parameter(ParameterSetName = 'RunUAT')]
    [Parameter(ParameterSetName = 'RunUBT')]
    [Parameter(ParameterSetName = 'RunEditor')]
    [string]$Preset = '',

    [Parameter(ParameterSetName = 'RunUAT')]
    [switch]$List,

    [switch]$ListPresets,
    [switch]$Help,

    [Parameter(DontShow)]
    [Parameter(ParameterSetName = 'Tests')]
    [switch]$RunTests
)

if ($PSVersionTable.PSVersion.Major -lt 7) {
    Write-Host "Powershell version 7 or higher is currently required to run this script"
    Write-Host "You can download the latest version from the Microsoft Store:"
    Write-Host "https://apps.microsoft.com/detail/9mz1snwt0n5d"
    exit 1
}

# Makeshift automation tests. Using with -WhatIf applies it to all the commands that will be ran.
if ($RunTests.IsPresent) {
    $Tests = @(
        "-All -RunPackagedGame"
        "-ProjectFiles -Build -Cook"
        "-Cook -Package -RunPackagedGame"
        "-RunEditor -CommandArgs '-Game -FullScreen -Log=SpecificLogName.txt'"
        "-BuildGraph '.\Path\To\BuildGraphScript.xml' -PassProjectInfo -CommandArgs '-set:Target=Game'"
        "-UnrealPak -PakFile 'Path\To\PakFile.pak' -CommandArgs '-List'"
        "-UnrealPak -PakFile 'PakFile.pak' -CommandArgs '-List'"
        "-UnrealPak -PakFile 'PakFile' -CommandArgs '-List'"
        "-UnrealPak -CommandArgs '-List'"
        "-RunUAT -CommandArgs 'BuildCookRun -Help'"
        "-RunUBT -CommandArgs '-ProjectFiles -Game -Rocket -Progress'"
    )

    foreach ($TestArgs in $Tests) {
        Write-Host "`n> Invoking [ '$PSCommandPath' $TestArgs ] <`n"
        Invoke-Expression "$PSCommandPath $TestArgs"
    }

    exit
}

if ($Help.IsPresent -and [string]::IsNullOrEmpty($BuildGraph) -and -not ($UnrealPak.IsPresent -or $RunUAT.IsPresent -or $RunUBT.IsPresent -or $RunEditor.IsPresent -$Ushell.IsPresent)) {
    if ($PSCmdlet.ShouldProcess("UnrealSuite.ps1", "Calling Get-Help on the script [ Get-Help '$PSScriptRoot\UnrealSuite.ps1' -Detailed ]")) {
        Get-Help "$PSCommandPath" -Detailed
    }
    exit
}

#region Types

class ProjectInfo {
    [string]$ProjectName
    [string]$ProjectPath
    [string]$RegistryPath
    [string]$EngineAssociation
    [string]$EnginePath
    [string]$StagingDirectory
    [string]$ArchiveDirectory

    [string] ToString() {
        $Result = "Project Info`n"
        $Result += "------------`n"
        $Result += "Registry Entry:     $($this.RegistryPath).$($this.EngineAssociation)`n"
        $Result += "Engine Path:        $($this.EnginePath)`n"

        $Result += "Project Path:       $($this.ProjectPath)`n"
        $Result += "Project Name:       $($this.ProjectName)`n"

        $Result += "StagingDirectory:   $($this.StagingDirectory)`n"
        $Result += "ArchiveDirectory:   $($this.ArchiveDirectory)"

        return $Result
    }
}

#endregion

#region Presets

$RunUATPresets = @{
    'List' = '-List'
    'Build' = 'BuildCookRun -noP4 -NoCompile -NoCompileEditor -UTF8Output -Build -SkipCook'
    'BuildEditor' = 'BuildCookRun -noP4 -NoCompile -Target=Editor -NoTools'
    'Cook' = 'BuildCookRun -noP4 -UTF8Output -NoCompileEditor -SkipBuildEditor -Cook'
    'Package' = 'BuildCookRun -noP4 -NoCompile -NoCompileEditor -SkipCook -Prereqs -Stage -Package -Pak -Compressed -Manifests -Archive'
    'Turnkey' = 'Turnkey'
    'TurnkeyHelp' = 'Turnkey -Command=Help -Using -Studio'
    'BuildCookRunHelp' = '-Help BuildCookRun'
}

$RunUBTPresets = @{
    'ProjectFiles' = '-ProjectFiles -Game -Rocket -Progress'
    'Clean' = '-Clean'
    'VSCodeProjectFiles' = '-VSCode'
}

$RunEditorPresets = @{
    'Game' = '-Game -FullScreen -Log -NewConsole'
    'GameAllowAttach' = '-Game -Log -NewConsole -WaitForDebugger'
    'ResavePackages' = '-Run=ResavePackages -NoShaderCompile -IgnoreChangelist -OnlySaveDirtyPackages -GCFREQ=1000 -ProjectOnly'
    'FixupRedirectors' = '-Run=ResavePackages -ProjectOnly -FixupRedirectors -SearchAllAssets -SkipCheckedOutPackages -AutoCheckOut -NoShaderCompile -GCFREQ=1000'
    'ResavePackagesSCM' = '-Run=ResavePackages -NoShaderCompile -OnlySaveDirtyPackages -ProjectOnly -AutoCheckOut -SearchAllAssets -SkipCheckedOutPackages -GCFREQ=1000'
    'ResaveAllPackages' = '-Run=ResavePackages -NoShaderCompile -IgnoreChangelist -ProjectOnly -GCFREQ=1000'
    'ResaveMapsOnly' = '-Run=ResavePackages -IgnoreChangelist -OnlySaveDirtyPackages -ProjectOnly -MapsOnly -NoShaderCompile -GCFREQ=1000'
    'ResaveActors' = '-Run=WorldPartitionBuilderCommandlet -OnlySaveDirtyPackages -Builder=WorldPartitionResaveActorsBuilder -NoShaderCompile -GCFREQ=1000'
    'RecompileBlueprints' = '-run=CompileAllBlueprints -ProjectOnly -NullRHI -NoShaderCompile'
    'FillDDC' = '-Run=DerivedDataCache -Fill -ProjectOnly -TargetPlatform="Windows,WindowsEditor" -NullRHI -LogCMDs=”LogDerivedDataCache Verbose”'
    'FillDDCMapsOnly' = '-Run=DerivedDataCache -Fill -MapsOnly -ProjectOnly -TargetPlatform="Windows,WindowsEditor" -NullRHI -LogCMDs=”LogDerivedDataCache Verbose”'
    'BuildNavigation' = '-Run=WorldPartitionBuilderCommandlet -AllowCommandletRendering -Builder=WorldPartitionNavigationDataBuilder'
    'SetupHLODs' = '-Run=WorldPartitionBuilderCommandlet -AllowCommandletRendering -Builder=WorldPartitionHLODsBuilder -SetupHLODs -NoShaderCompile -OnlySaveDirtyPackages -GCFREQ=1000'
    'BuildHLODs' = '-Run=WorldPartitionBuilderCommandlet -AllowCommandletRendering -Builder=WorldPartitionHLODsBuilder -BuildHLODs -NoShaderCompile -OnlySaveDirtyPackages -GCFREQ=1000'
    'FinalizeHLODs' = '-Run=WorldPartitionBuilderCommandlet -AllowCommandletRendering -Builder=WorldPartitionHLODsBuilder FinalizeHLODs -NoShaderCompile -OnlySaveDirtyPackages -GCFREQ=1000'
    'DeleteHLODs' = '-Run=WorldPartitionBuilderCommandlet -AllowCommandletRendering -Builder=WorldPartitionHLODsBuilder -DeleteHLODs -NoShaderCompile -OnlySaveDirtyPackages -GCFREQ=1000'
    'BuildMiniMap' = '-Run=WorldPartitionBuilderCommandlet -AllowCommandletRendering -Builder=WorldPartitionMiniMapBuilder'
    'RunAllTests' = '-Unattended -NoPause -NullRHI -ExecCmds="Automation RunAll; quit" -TestExit="Automation Test Queue Empty" -Log -NewConsole'
}

#endregion

#region Functions

function Write-Presets {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$CommandName,

        [Parameter(Mandatory)]
        [hashtable]$PresetList
    )

    Write-Host "$CommandName Presets"
    1..$CommandName.Length | ForEach-Object { Write-Host -NoNewline "-" }
    Write-Host -NoNewline "--------"
    $PresetList.GetEnumerator() | Sort-Object -Property Key | ForEach-Object { $_ } | Format-Table -Property @{Expression="   "},Name,@{Expression="   "},Value -Wrap -HideTableHeaders
}

function Get-EngineInfo { 
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$InEngineAssociation,

        [string]$InRegistryPath = ''
    )

    if ([string]::IsNullOrEmpty($InEngineAssociation)) {
        Exit-OnError -ForceError -Message 'Provided empty Engine Association.'
    }

    $OutRegistryPath = ''
    $OutEnginePath = ''

    # If EnginePath was not provided, look for the Engine within the provided path
    if ([string]::IsNullOrEmpty($OutEnginePath) -and -not [string]::IsNullOrEmpty($InRegistryPath)) {
        $OutRegistryPath = $InRegistryPath
        if (Test-Path "Registry::$OutRegistryPath") {
            if ((Get-ItemProperty -Path "Registry::$OutRegistryPath" | Format-List).Contains('InstalledDirectory')) {
                $OutEnginePath = (Get-ItemProperty -Path "Registry::$OutRegistryPath" -Name 'InstalledDirectory').'InstalledDirectory'.Replace('"', '')
            }
        }
    }

    # If EnginePath was not found, look for the Engine within vanilla versions
    if ([string]::IsNullOrEmpty($OutEnginePath)) {
        # Vanilla Engines registry directory
        $OutRegistryPath = "HKEY_LOCAL_MACHINE\SOFTWARE\EpicGames\Unreal Engine\$InEngineAssociation"
        if (Test-Path "Registry::$OutRegistryPath") {
            $OutEnginePath = (Get-ItemProperty -Path "Registry::$OutRegistryPath" -Name 'InstalledDirectory').'InstalledDirectory'.Replace('"', '')
        }
    }

    # If EnginePath was not found, look for the Engine within custom versions
    if ([string]::IsNullOrEmpty($OutEnginePath)) {
        # Custom Engines registry directory
        $OutRegistryPath = 'HKEY_CURRENT_USER\Software\Epic Games\Unreal Engine\Builds'
        $OutEnginePath = (Get-ItemProperty -Path "Registry::$OutRegistryPath" -Name $InEngineAssociation).$InEngineAssociation.Replace('"', '')
    }

    return [PSCustomObject]@{
        RegistryPath = $OutRegistryPath
        EnginePath = $OutEnginePath
    }
}

# Keeping as separate parameters even though we have ProjectInfo class - it may end up in a module and I don't want to refactor too much. It's not very inconvenient at the moment.
function Get-ProjectInfo {
    [CmdletBinding()]
    param(
        [string]$InProjectName = '',
        [string]$InProjectPath = '',
        [string]$InRegistryPath = '',
        [string]$InEngineAssociation = '',
        [string]$InEnginePath = '',
        [string]$InStagingDirectory = '',
        [string]$InArchiveDirectory = ''
    )

    $OutProjectInfo = [ProjectInfo]@{
        ProjectName = $InProjectName
        ProjectPath = $InProjectPath
        RegistryPath = $InRegistryPath
        EnginePath = $InEnginePath
        StagingDirectory = $InStagingDirectory
        ArchiveDirectory = $InArchiveDirectory
        EngineAssociation = $InEngineAssociation
    }

    # Look for the .uproject file
    if ([string]::IsNullOrEmpty($OutProjectInfo.ProjectName) -or [string]::IsNullOrEmpty($OutProjectInfo.ProjectPath) -or [string]::IsNullOrEmpty($OutProjectInfo.EngineAssociation)) {
        $Paths = $(Get-Location),"$PSScriptRoot\","$PSScriptRoot\..\"
        if (-not [string]::IsNullOrEmpty($InProjectPath)) {
            $Paths += $InProjectPath
        }

        $ProjectNameFilter = '*.uproject'
        if (-not [string]::IsNullOrEmpty($InProjectName)) {
            $ProjectNameFilter = "$InProjectName.uproject"
        }

        $FoundUprojects = Get-ChildItem -Path $Paths -Filter $ProjectNameFilter -File
        if ($FoundUprojects.Count -eq0) {
            Exit-OnError -ForceError -Message "No projects found at those locations`n`t$Paths"
        }
        $UprojectFile = $FoundUprojects[0]

        foreach ($UprojectFile in $FoundUprojects) {
            $OutProjectInfo.ProjectName = [System.IO.Path]::GetFileNameWithoutExtension($UprojectFile)
            $OutProjectInfo.ProjectPath = [System.IO.Path]::GetDirectoryName($UprojectFile)

            if ([string]::IsNullOrEmpty($OutProjectInfo.EngineAssociation)) {
                $Uproject = Get-Content "$($OutProjectInfo.ProjectPath)\$($OutProjectInfo.ProjectName).uproject" -Raw | ConvertFrom-Json
                $OutProjectInfo.EngineAssociation = $Uproject.EngineAssociation
            }

            break
        }

        if ([string]::IsNullOrEmpty($OutProjectInfo.ProjectName) -or [string]::IsNullOrEmpty($OutProjectInfo.ProjectPath)) {
            Exit-OnError -ForceError -Message "Couldn't find the project."
        }
    }

    # Determine the Staging Directory
    if ([string]::IsNullOrEmpty($OutProjectInfo.StagingDirectory)) {
        $OutProjectInfo.StagingDirectory = "$($OutProjectInfo.ProjectPath)\Saved\StagedBuilds"
    }

    # Determine the Archive Directory
    if ([string]::IsNullOrEmpty($OutProjectInfo.ArchiveDirectory)) {
        $OutProjectInfo.ArchiveDirectory = "$($OutProjectInfo.ProjectPath)\Build"
    }

    $EngineInfo = Get-EngineInfo -InRegistryPath "$($OutProjectInfo.RegistryPath)" -InEngineAssociation "$($OutProjectInfo.EngineAssociation)"
    $OutProjectInfo.RegistryPath = $EngineInfo.RegistryPath
    $OutProjectInfo.EnginePath = $EngineInfo.EnginePath

    if ([string]::IsNullOrEmpty($OutProjectInfo.EnginePath)) {
        Exit-OnError -ForceError -Message "Couldn't find the associated Engine."
    }

    return $OutProjectInfo
}

function Exit-OnError {
    [CmdletBinding()]
    param(
        [string]$Message,
        [switch]$ForceError
    )

    if ($LASTEXITCODE -ne 0 -or $ForceError) {
        # force a newline on error
        Write-Host "`nSCRIPT: [ ERROR ] $Message"
        if (-not $ContinueDespiteErrors.IsPresent) {
            Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
            Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
            exit 1
        }
    }
}

function Invoke-UnrealCommand {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$ExecutablePath,
        [string]$CommandArgs,
        [hashtable]$Presets,
        [string]$Preset,
        [string]$AdditionalArgs,
        [switch]$AltArgsOrder # used in RunUBT and RunEditor - should probably look for a better solution
    )

    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ Invoke Command                                                                          │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'

    if (-not [string]::IsNullOrEmpty($Preset) -and $Presets.Contains($Preset)) {
        $PresetContent = $Presets[$Preset]
        if (-not [string]::IsNullOrEmpty($Preset)) {
            if (-not [string]::IsNullOrEmpty($PresetContent)) {
                $CommandArgs = "$PresetContent $CommandArgs"
            } else {
                Exit-OnError -ForceError -Message 'Failed to find preset.'
            }
        }
    }

    $CompleteCommand = "$ExecutablePath $CommandArgs $AdditionalArgs"
    if ($AltArgsOrder.IsPresent) {
        $CompleteCommand = "$ExecutablePath $AdditionalArgs $CommandArgs"
    }

    Write-Host "SCRIPT: [ START ] Running $CompleteCommand"
    if ($Help.IsPresent) {
        if ($PSCmdlet.ShouldProcess("$ExecutablePath", "Calling an executable with the '-Help' parameter. [ $ExecutablePath -Help ]")) {
            Invoke-Expression "$ExecutablePath -Help"
        }
    } else {
        if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling Unreal Command [ $CompleteCommand ].")) {
            Invoke-Expression $CompleteCommand
            Exit-OnError -Message "Failed to invoke command."
        }
    }
    # a newline, since on error sometimes it's missing and the message lands at the previous line's end
    Write-Host "`nSCRIPT: [ END ] Running $CompleteCommand"
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
}

#endregion

#region Startup

# Gather info required to run this script (most importantly project name & path and associated engine version path)
$ProjectInfo = Get-ProjectInfo -InProjectName $ProjectName -InProjectPath $ProjectPath -InEngineAssociation $EngineAssociation -InRegistryPath $RegistryPath -InEnginePath $EnginePath -InStagingDirectory $StagingDirectory -InArchiveDirectory $ArchiveDirectory
$ProjectName = $ProjectInfo.ProjectName
$ProjectPath = $ProjectInfo.ProjectPath
$RegistryPath = $ProjectInfo.RegistryPath
$EngineAssociation = $ProjectInfo.EngineAssociation
$EnginePath = $ProjectInfo.EnginePath
$StagingDirectory = $ProjectInfo.StagingDirectory
$ArchiveDirectory = $ProjectInfo.ArchiveDirectory

# Determine executable paths
$RunUATPath = "$EnginePath\Engine\Build\BatchFiles\RunUAT.bat"
$UnrealBuildToolPath = "$EnginePath\Engine\Binaries\DotNET\UnrealBuildTool\UnrealBuildTool.exe"
$UnrealEditorPath = "$EnginePath\Engine\Binaries\Win64\UnrealEditor.exe"
$UnrealEditorCMDPath = "$EnginePath\Engine\Binaries\Win64\UnrealEditor-CMD.exe"
$UnrealPakPath = "$EnginePath\Engine\Binaries\Win64\UnrealPak.exe"
$UshellPath = "$EnginePath\Engine\Extras\ushell\ushell.bat"

Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
Write-Host '██╗   ██╗███╗   ██╗██████╗ ███████╗ █████╗ ██╗         ███████╗██╗   ██╗██╗████████╗███████╗'
Write-Host '██║   ██║████╗  ██║██╔══██╗██╔════╝██╔══██╗██║         ██╔════╝██║   ██║██║╚══██╔══╝██╔════╝'
Write-Host '██║   ██║██╔██╗ ██║██████╔╝█████╗  ███████║██║         ███████╗██║   ██║██║   ██║   █████╗  '
Write-Host '██║   ██║██║╚██╗██║██╔══██╗██╔══╝  ██╔══██║██║         ╚════██║██║   ██║██║   ██║   ██╔══╝  '
Write-Host '╚██████╔╝██║ ╚████║██║  ██║███████╗██║  ██║███████╗    ███████║╚██████╔╝██║   ██║   ███████╗'
Write-Host ' ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝    ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝'
Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'

# Display build setup info
Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
Write-Host '├─ SETUP                                                                                   │'
Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'

Write-Host $ProjectInfo.ToString();

Write-Host "`nDefaults"
Write-Host "--------"
Write-Host "Platform:           $Platform"
Write-Host "Configuration:      $Configuration"

if ($ListPresets.IsPresent)
{
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ List Presets                                                                            │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
    Write-Presets -CommandName "RunUAT" -PresetList $RunUATPresets
    Write-Presets -CommandName "RunUBT" -PresetList $RunUBTPresets
    Write-Presets -CommandName "RunEditor" -PresetList $RunEditorPresets
    Write-Host 'SCRIPT: [ FINISHED ] Command completed successfully'
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
}

#endregion

#region Generic Commands

# Perform RunUAT if requested
if ($RunUAT.IsPresent) {
    $AdditionalArgs = "-Project='$ProjectPath\$ProjectName.uproject' -Configuration='$Configuration' -Platform='$Platform'"
    if ($List.IsPresent) {
        $CommandArgs = "-List"
    }
    if ($CommandArgs.Contains("-List") -or $CommandArgs.Contains("-Help")) {
        $AdditionalArgs = ''
    }
    Invoke-UnrealCommand -ExecutablePath "$RunUATPath" -CommandArgs $CommandArgs -Presets $RunUATPresets -Preset "$Preset" -AdditionalArgs $AdditionalArgs
    exit
}

# Perform RunUBT if requested
if ($RunUBT.IsPresent) {
    Invoke-UnrealCommand -ExecutablePath "$UnrealBuildToolPath" -CommandArgs $CommandArgs -Presets $RunUBTPresets -Preset "$Preset" -AdditionalArgs "-Project='$ProjectPath\$ProjectName.uproject'" -AltArgsOrder
    exit
}

# Perform RunEditor if requested
if ($RunEditor.IsPresent) {
    $EditorPath = $UnrealEditorCMDPath
    if ($NoCMD.IsPresent) {
        $EditorPath = $UnrealEditorPath
    }

    Invoke-UnrealCommand -ExecutablePath "$EditorPath" -CommandArgs $CommandArgs -Presets $RunEditorPresets -Preset "$Preset" -AdditionalArgs "'$ProjectPath\$ProjectName.uproject' '$Map'" -AltArgsOrder
    exit
}

# Run UnrealPak if requested
if ($UnrealPak.IsPresent) {
    $SearchLocations = @(
        "$ArchiveDirectory\Windows\$ProjectName\Content\Paks"
        "$StagingDirectory\Windows\$ProjectName\Content\Paks"
        (Get-Location).Path
        "$PSScriptRoot"
    )

    $FileNamesToTest = @(
        "$ProjectName-Windows"
        "$ProjectName-WindowsNoEditor"
        'pakchunk0-Windows'
        'pakchunk0-WindowsNoEditor'
    )

    $Extensions = @(
        '.utoc'
        '.ucas'
        '.pak'
    )

    $PakFilePath = [System.IO.Path]::GetDirectoryName($PakFile)
    $PakFileName = [System.IO.Path]::GetFileNameWithoutExtension($PakFile)
    $Extension = ''
    if ($PakFile.Contains('.')) {
        $Extension = [System.IO.Path]::GetExtension($PakFile)
        $Extension = $Extension.Replace('.', '')
        $Extensions = @( $Extension )
    }

    if (-not [string]::IsNullOrEmpty($PakFileName)) {
        $FileNamesToTest = @( "$PakFileName" )
    }

    $FullPakFilePath = "$PackFilePath\$PakFileName.$Extension"
    if ($FullPakFilePath -eq '\.' -or -not (Test-Path -Path "$FullPakFilePath")) {
        $FullPakFilePath = ''
        :loop foreach ($FileName in $FileNamesToTest) {
            foreach ($Path in $SearchLocations) {
                if (-not [string]::IsNullOrEmpty($PakFilePath)) {
                    $Path = "$Path\$PakFilePath"
                }
                foreach ($Extension in $Extensions) {
                    $Extension = $Extension.Replace('.', '')
                    $TestedPath = "$Path\$FileName.$Extension"
                    Write-Host "LookingFor $TestedPath"
                    if (Test-Path -Path $TestedPath) {
                        $FullPakFilePath = $TestedPath
                        break loop
                    }
                }
            }
        }
    }

    if (-not $Help.IsPresent) {
        if (-not [string]::IsNullOrEmpty($FullPakFilePath)) {
            Write-Host "Using PakFile '$FullPakFilePath'"
        } elseif (-not [string]::IsNullOrEmpty($PakFile)) {
            Exit-OnError -ForceError -Message "Could not find the PakFile '$PakFile' in:`n`t$SearchLocations`n`tMake sure you have staged or packaged your build."
        }
    }

    Invoke-UnrealCommand -ExecutablePath "$UnrealPakPath" -CommandArgs $CommandArgs -Presets $RunEditorPresets -Preset "$Preset" -AdditionalArgs "$FullPakFilePath" -AltArgsOrder
    exit
}

# Run BuildGraph if requested
if (-not [string]::IsNullOrEmpty($BuildGraph)) {
    if ($PassProjectInfo.IsPresent) {
        $Defaults = "-set:ProjectPath='$ProjectPath' -set:ProjectName='$ProjectName' -set:EngineAssociation='$EngineAssociation' -set:EnginePath='$EnginePath' -set:Platform='$Platform' -set:Configuration='$Configuration'"
        $CommandArgs = "$Defaults $CommandArgs"
    }
    Invoke-UnrealCommand -ExecutablePath "$RunUATPath" -CommandArgs $CommandArgs -AdditionalArgs "-Script='$BuildGraph'" -AltArgsOrder
    exit
}

# Run ushell if requested
if ($Ushell.IsPresent) {
    if (-not (Test-Path -Path $UshellPath)) {
        Exit-OnError -ForceError -Message 'Could not find ushell.bat. Make sure it has been included with your engine distribution.'
    }
    if ($PSCmdlet.ShouldProcess("$EngineAssociation", "Calling [ $UshellPath ].")) {
        if ($Help.IsPresent) {
            # Invoke-Expression "cmd.exe /d/k 'call $UshellPath && .help readme && exit'"
            # Invoke-Expression "cmd.exe /d/k 'call $UshellPath && .info && exit'"
            # Invoke-Expression "cmd.exe /d/k $UshellPath --help"
            # Write-Host "Try running ushell and using '.help readme' for more detailed information."
            
            Invoke-Expression "cmd.exe /d/k 'call $UshellPath && .help readme && exit'"
        } else {
            # $Args = "--project='$ProjectPath/$ProjectName.uproject'" # platform, configuration, etc.
            # Invoke-Expression "cmd.exe /d/k call $UshellPath $Args && $CommandArgs" # && exit

            # Invoke-Expression "cmd.exe /d/k 'call $UshellPath && .info && exit'"
            Invoke-Expression "cmd.exe /d/k $UshellPath"
        }
    }
    exit
}

#endregion

#region Build Pipeline

# BUILD STEP: Generate solution
if ($ProjectFiles.IsPresent -or $All.IsPresent) {
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ Generate VS Project Files                                                               │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
    Write-Host 'SCRIPT: [ START ] Generating VS project files'
    $Command = "$UnrealBuildToolPath -Project='$ProjectPath\$ProjectName.uproject' -ProjectFiles -Game -Rocket -Progress"
    if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling [ $Command ].")) {
        Invoke-Expression $Command
        Exit-OnError -Message 'Failed to generate VS project files.'
    }

    Write-Host 'SCRIPT: [ END ] Generating VS project files'
}

# BUILD STEP: Build
if ($Build.IsPresent -or $BuildEditor.IsPresent -or $BuildGame.IsPresent -or $All.IsPresent) {
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ Build Binaries                                                                          │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
    Write-Host 'SCRIPT: [ START ] Building binaries'

    if ($Clean.IsPresent) {
        $AdditionalBuildEditorParameters = "-Clean $AdditionalBuildEditorParameters"
        $AdditionalBuildGameParameters = "-Clean $AdditionalBuildGameParameters"
    }

    # BUILD STEP: Build Editor
    if ($BuildEditor.IsPresent -or $Build.IsPresent -or $All.IsPresent) {
        Write-Host '╒═════════════════════════════════════════════╕'
        Write-Host '├─ Build Editor Binaries                      │'
        Write-Host '╘═════════════════════════════════════════════╛'
        Write-Host 'SCRIPT: [ START ] Building Editor binaries'
        $Command = "$RunUATPath BuildTarget -Project='$ProjectPath\$ProjectName.uproject' -noP4 -Configuration=$Configuration -Target=Editor -Platform=$Platform -NoTools -NoXGE $AdditionalBuildEditorParameters"
        if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling [ $Command ].")) {
            Invoke-Expression $Command
            Exit-OnError -Message 'Failed to build Editor binaries.'
        }

        Write-Host 'SCRIPT: [ END ] Building Editor binaries'
    }

    # BUILD STEP: Build Game
    if ($BuildGame.IsPresent -or $Build.IsPresent -or $All.IsPresent) {
        Write-Host '╒═════════════════════════════════════════════╕'
        Write-Host '├─ Build Game Binaries                        │'
        Write-Host '╘═════════════════════════════════════════════╛'
        Write-Host 'SCRIPT: [ START ] Building Game binaries'
        $Command = "$RunUATPath BuildCookRun -Project='$ProjectPath\$ProjectName.uproject' -noP4 -ClientConfig=$Configuration -ServerConfig=$Configuration -NoCompile -NoCompileEditor -UTF8Output -Platform=$Platform -Build -SkipCook $AdditionalBuildGameParameters"
        if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling [ $Command ].")) {
            Invoke-Expression $Command
            Exit-OnError -Message 'Failed to build Game binaries.'
        }

        Write-Host 'SCRIPT: [ END ] Building Game binaries'
    }

    Write-Host 'SCRIPT: [ END ] Building binaries'
}

# BUILD STEP: Cook
if ($Cook.IsPresent -or $All.IsPresent) {
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ Cook                                                                                    │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
    Write-Host 'SCRIPT: [ START ] Cooking'
    if (-not $NoIterativeCooking.IsPresent) {
        $AdditionalCookParameters = "-iterate $AdditionalCookParameters"
    }

    if (-not [string]::IsNullOrEmpty($ReleaseVersionName)) {
        $AdditionalCookParameters = "-createreleaseversion='$ReleaseVersionName' $AdditionalCookParameters"
    }

    $Command = "$RunUATPath BuildCookRun -noP4 -UTF8Output -NoCompileEditor -SkipBuildEditor -Cook -Project='$ProjectPath\$ProjectName.uproject' -Target=$ProjectName -UnrealEXE='$UnrealEditorCMDPath' -Platform=$Platform -SkipStage $AdditionalCookParameters"
    if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling [ $Command ].")) {
        Invoke-Expression $Command
        Exit-OnError -Message 'Failed to Cook game content.'
    }

    Write-Host 'SCRIPT: [ END ] Cooking'
}

# BUILD STEP: Package
if ($Package.IsPresent -or $All.IsPresent) {
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ Package                                                                                 │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
    Write-Host 'SCRIPT: [ START ] Packaging'
    $Command = "$RunUATPath BuildCookRun -Project='$ProjectPath\$ProjectName.uproject' -noP4 -ClientConfig=$Configuration -ServerConfig=$Configuration -NoCompile -NoCompileEditor -SkipCook -Prereqs -Stage -Package -Pak -Compressed -Manifests -Archive -StagingDirectory='$StagingDirectory' -ArchiveDirectory='$ArchiveDirectory' $AdditionalPackageParameters"
    if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling [ $Command ].")) {
        Invoke-Expression $Command
        Exit-OnError -Message 'Failed to Package the game.'
    }

    Write-Host 'SCRIPT: [ END ] Packaging'
}

# BUILD STEP: Run Packaged Game
if ($RunPackagedGame.IsPresent) {
    Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
    Write-Host '├─ Run Packaged Game                                                                       │'
    Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'
    Write-Host 'SCRIPT: [ START ] Runing packaged game'
    $Command = "$ArchiveDirectory\Windows\$ProjectName.exe -Log -NewConsole $AdditionalRunPackagedGameParameters"
    if ($PSCmdlet.ShouldProcess("$ProjectName", "Calling [ $Command ].")) {
        Invoke-Expression $Command
        Exit-OnError -Message 'Failed to run packaged game.'
    }

    Write-Host 'SCRIPT: [ END ] Running packaged game'
}

#endregion

Write-Host "`nSCRIPT: [ FINISHED ] Command completed successfully"
Write-Host '╒══════════════════════════════════════════════════════════════════════════════════════════╕'
Write-Host '╘══════════════════════════════════════════════════════════════════════════════════════════╛'

<#

MIT License

Copyright (c) 2024 Krzysztof Pachulski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

#>
