<#PSScriptInfo
  .VERSION      0.1.2
  .GUID         b95fb1ac-6878-4451-bb49-434d51d9555d
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/posts/2023/10/2a73410a-6611-570c-9ab4-dc8cc8998146/
#>

#Requires -Version 7.2

<#
  .SYNOPSIS
  Video compression script based on FFmpeg.

  .DESCRIPTION
  FFmpeg is a free and open-source software project consisting of a suite of libraries and programs for handling video, audio, and other multimedia files and streams.

  .PARAMETER P_Files
  An array of input files.

  .PARAMETER P_vCodec
  The video codec.
  Default: 'libx265'.

  .PARAMETER P_aCodec
  The audio codec.
  Default: 'copy'.

  .PARAMETER P_Framerate
  FFmpeg can be used to change the frame rate of an existing video, such that the output frame rate is lower or higher than the input frame rate. The output duration of the video will stay the same.
  This is useful when working with, for example, high-framerate input video that needs to be temporally scaled down for devices that do not support high FPS.
  When the frame rate is changed, FFmpeg will drop or duplicate frames as necessary to achieve the targeted output frame rate.

  .PARAMETER P_CRF
  Constant Rate Factor.
  Use this rate control mode if you want to keep the best quality and care less about the file size. This is the recommended rate control mode for most uses.
  This method allows the encoder to attempt to achieve a certain output quality for the whole file when output file size is of less importance. This provides maximum compression efficiency with a single pass. By adjusting the so-called quantizer for each frame, it gets the bitrate it needs to keep the requested quality level. The downside is that you can't tell it to get a specific filesize or not go over a specific size or bitrate, which means that this method is not recommended for encoding videos for streaming.

  .PARAMETER P_Preset
  A preset is a collection of options that will provide a certain encoding speed to compression ratio. A slower preset will provide better compression (compression is quality per filesize). This means that, for example, if you target a certain file size or constant bit rate, you will achieve better quality with a slower preset. Similarly, for constant quality encoding, you will simply save bitrate by choosing a slower preset.

  .PARAMETER P_Extension
  The extension of the resulting files.
  Default: 'mp4'.

  .EXAMPLE
  .\ffmpeg.video.compress.ps1 -F 'file_01.mov', 'file_02.mov', 'file_03.mov'

  .EXAMPLE
  .\ffmpeg.video.compress.ps1 -F '*.mov'

  .LINK
  https://lib.onl/ru/posts/2023/10/2a73410a-6611-570c-9ab4-dc8cc8998146/
#>

Param(
  [Parameter(Mandatory, HelpMessage="An array of input files.")]
  [Alias('F')][string[]]$P_Files,

  [Parameter(HelpMessage="The video codec.")]
  [Alias('CV')][string]$P_vCodec = 'libx265',

  [Parameter(HelpMessage="The audio codec.")]
  [Alias('CA')][string]$P_aCodec = 'copy',

  [Parameter(HelpMessage="FFmpeg can be used to change the frame rate of an existing video, such that the output frame rate is lower or higher than the input frame rate.")]
  [Alias('R')][int]$P_Framerate,

  [Parameter(HelpMessage="Constant Rate Factor. Use this rate control mode if you want to keep the best quality and care less about the file size.")]
  [Alias('C')][int]$P_CRF,

  [Parameter(HelpMessage="A preset is a collection of options that will provide a certain encoding speed to compression ratio.")]
  [Alias('P')][string]$P_Preset,

  [Parameter(HelpMessage="The extension of the resulting files.")]
  [Alias('EXT')][string]$P_Extension = 'mp4'
)

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# New line separator.
$NL = "$([Environment]::NewLine)"

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Compress-Video
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMPRESS VIDEO.
# -------------------------------------------------------------------------------------------------------------------- #

function Compress-Video() {
  $Files = (Get-ChildItem "${P_Files}" -File)

  $Files | ForEach-Object {
    $In = "$($_.FullName)"
    $Out = "$(Join-Path $_.DirectoryName $_.BaseName).${P_Extension}"
    Start-FFmpeg -I "${In}" -O "${Out}"
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# TESTING ELEMENTS.
# -------------------------------------------------------------------------------------------------------------------- #

function Test-Data() {
  param (
    [Alias('T')][string]$Type,
    [Alias('P')][string]$Path
  )

  switch ($Type) {
    'D' { $Type = 'Container' }
    'F' { $Type = 'Leaf' }
  }

  Test-Path -LiteralPath "${Path}" -PathType "${Type}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# APP: FFmpeg.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-FFmpeg() {
  param (
    [Alias('I')][string]$In,
    [Alias('O')][string]$Out
  )

  # Search 'ffmpeg.exe'.
  $FFmpegExe = ((Get-ChildItem -LiteralPath "${PSScriptRoot}" -Filter 'ffmpeg.exe' -Recurse -File) | Select-Object -First 1)

  # Checking the location of 'ffmpeg.exe'.
  if (-not (Test-Data -T 'F' -P "${FFmpegExe}")) {
    Write-Warning -WarningAction 'Stop' -Message ("'ffmpeg.exe' not found!${NL}${NL}" +
    "1. Download FFmpeg from 'https://www.gyan.dev/ffmpeg/builds/'.${NL}" +
    "2. Extract 'ffmpeg.exe' into a directory '${PSScriptRoot}'.")
  }

  # Specifying 'ffmpeg.exe' parameters.
  $Params = @('-hide_banner')
  $Params += @('-i', "${In}")
  $Params += @('-c:v', "${P_vCodec}")
  if ($P_CRF) { $Params += @('-crf', "${P_CRF}") }
  if ($P_Preset) { $Params += @('-preset', "${P_Preset}") }
  if ($P_Framerate) { $Params += @('-r', "${P_Framerate}") }
  $Params += @('-c:a', "${P_aCodec}")
  $Params += @("${Out}")

  # Running 'ffmpeg.exe'.
  & "${FFmpegExe}" $Params
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
