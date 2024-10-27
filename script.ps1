param (
    [Parameter(Position = 0, Mandatory = $true)]
    [string]$inputBaseDir = "D:\some_dir_containing_dirs_containing_.h264_files",
    [Parameter(Position = 1, Mandatory = $false)]
    [string]$outputDir = "E:\merged_videos",
    [Parameter(Position = 2, Mandatory = $false)]
    [string]$ffmpegPath = "ffmpeg.exe",
    [Parameter(Position = 3, Mandatory = $true)]
    [ValidateSet("true", "false")]
    [string]$reencode = "false",
    [Parameter(Position = 4, Mandatory = $false)]
    [ValidateSet("none", "intel", "amd")]
    [string]$hardwareAccel = "none"  # Opzioni: "intel", "amd", "none"
)

# Function: concatenate videos in inputBaseDir subfolders
function Concatenate-Videos {
    param (
        [string]$inputFolder,
        [string]$intermediateFile,
        [string]$ffmpegPath
    )

    # Search fo all .h264 files inside inputBaseDir sub-irectories (recursively)
    # and create a list of ordered sub-directory\file_name
    $h264Files = Get-ChildItem -Path $inputFolder -Recurse -Filter "*.h264" | Sort-Object DirectoryName, Name

    # Create tmp file with ordered list of file to concatenate
    $concatFile = [System.IO.Path]::Combine($env:TEMP, "ffmpeg_concat_$(Get-Random).txt")

    # Write list in the text file (ffmpeg readable)
    $h264Files | ForEach-Object {
        Add-Content -Path $concatFile -Value ("file '" + $_.FullName + "'")
    }

    # Compose ffmpeg concat command
    $ffmpegCommand = "$ffmpegPath -f concat -safe 0 -i `"$concatFile`" -c copy -y `"$intermediateFile`""

    # ffmpeg execution
    Write-Host "Concatenating file: $ffmpegCommand"
    Invoke-Expression $ffmpegCommand

    # Remove tmp list file
    Remove-Item $concatFile
}

# Function to re-encode video to h265 with hardware acceleration option
function Reencode-Video {
    param (
        [string]$intermediateFile,
        [string]$finalOutputFile,
        [string]$ffmpegPath,
        [string]$hardwareAccel
    )

    # Define the acceleration codec based on the hardwareAccel parameter
    switch ($hardwareAccel.ToLower()) {
        "intel" { $codec = "hevc_qsv" }  # Intel QuickSync [try this on Intel cpu]
        "amd" { $codec = "hevc_amf" }    # AMD Accelerated Media Framework (AMF) [try this on AMD cpu]
        "none" { $codec = "libx265" }    # Software encoding con x265 [Worst performance]
        default { throw "Invalid value for -hardwareAccel. Use 'intel', 'amd' or 'none'." }
    }

    # Command to re-encode video to h265 with or without hardware acceleration
    $ffmpegCommand = "$ffmpegPath -i `"$intermediateFile`" -c:v $codec -y `"$finalOutputFile`""
    
    # ffmpeg execution
    Write-Host "Ricodifica file: $ffmpegCommand"
    Invoke-Expression $ffmpegCommand
}

# Define re-econding variable based on the hardwareAccel parameter
switch ($reencode.ToLower()) {
    "true" { $reencode = $true }    # Disable reencoding
    "false" { $codec = $false }     # Enable reencoding
    default { throw "Invalid value for -reencode. Use 'true', 'false'." }
}

# Search all directories containing video files
$directories = Get-ChildItem -Path $inputBaseDir -Directory | Sort-Object FullName

foreach ($dir in $directories) {
    # Find .h264 files in each directory (if they exist)
    $h264Files = Get-ChildItem -Path $dir.FullName -Recurse -Filter "*.h264"
    
    if ($h264Files.Count -gt 0) {
        # Name of intermediate file and output file
        $intermediateFile = Join-Path $outputDir ($dir.Name + ".mp4")
        $outputFile = Join-Path $outputDir ($dir.Name + "_final.mp4")

        # Step 1: Concatenation without recoding
        Concatenate-Videos -inputFolder $dir.FullName -intermediateFile $intermediateFile -ffmpegPath $ffmpegPath

        # Step 2: Reencode the concatenated file, only if $reencode is $true
        if ($reencode) {
            Reencode-Video -intermediateFile $intermediateFile -finalOutputFile $outputFile -ffmpegPath $ffmpegPath -hardwareAccel $hardwareAccel
            # Remove intermediate file only if re-encoding has been done
            Remove-Item $intermediateFile
        }
    }
}
