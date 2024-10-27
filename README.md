# Video Concatenation and Encoding Script

This script, written in PowerShell, uses FFmpeg to concatenate multiple `.h264` video files within a given directory structure and optionally re-encodes the merged output to H.265 format. The script supports hardware-accelerated encoding using Intel QuickSync, AMD AMF, or CPU-only encoding if no acceleration is specified.

## Requirements

1. **Operating System**: Windows
2. **FFmpeg**: The script requires FFmpeg to handle video concatenation and re-encoding. Installation instructions are included below.

### Installation of FFmpeg

You can install FFmpeg using the Windows Package Manager, `winget`:

```powershell
winget install Gyan.FFmpeg
```

After installation, take note of the `ffmpeg.exe` path (you may need to specify it when running the script).

## Usage
### Command Structure

```powershell
.\script.ps1 -inputBaseDir "<input-directory>" -outputDir "<output-directory>" -ffmpegPath "<path-to-ffmpeg>" -reencode <true|false> -hardwareAccel <intel|amd|none>
```

### Parameters

- `inputBaseDir`: (Required) The base directory containing `.h264` video files organized in subdirectories.
- `outputDir`: (Required) The directory where output videos will be saved after processing.
- `ffmpegPath`: (Optional) Path to `ffmpeg.exe`. If not provided, it defaults to `"ffmpeg.exe"`.
- `reencode`: (Optional) Boolean value (`true` or `false`) to specify whether to re-encode the concatenated video.
    - If `false`, the output will not be re-encoded but will still be viewable.
    - If `true`, the video will be re-encoded in H.265 format.
- `hardwareAccel`: (Optional) Specifies the type of hardware acceleration to use. Accepts `"intel"`, `"amd"`, or `"none"`.
    - `intel`: Uses Intel QuickSync if available.
    - `amd`: Uses AMD AMF if available.
    - `none`: Disables hardware acceleration and encodes using the CPU only.

### Example Commands

Intel QuickSync Acceleration:
```powershell
.\script.ps1 -inputBaseDir "D:\Videos\Project" -outputDir "E:\ProcessedVideos" -ffmpegPath "C:\path\to\ffmpeg.exe" -reencode $true -hardwareAccel "intel"
```

AMD AMF Acceleration:
```powershell
.\script.ps1 -inputBaseDir "D:\Videos\Project" -outputDir "E:\ProcessedVideos" -ffmpegPath "C:\path\to\ffmpeg.exe" -reencode $true -hardwareAccel "amd"
```

No Hardware Acceleration:
```powershell
.\script.ps1 -inputBaseDir "D:\Videos\Project" -outputDir "E:\ProcessedVideos" -ffmpegPath "C:\path\to\ffmpeg.exe" -reencode $true -hardwareAccel "none"
```

No Hardware Acceleration (more simply):
```powershell
.\script.ps1 -inputBaseDir "D:\Videos\Project" -outputDir "E:\ProcessedVideos" -ffmpegPath "C:\path\to\ffmpeg.exe"
```

Concatenation without Re-encoding:
```powershell
    .\script.ps1 -inputBaseDir "D:\Videos\Project" -outputDir "E:\ProcessedVideos" -ffmpegPath "C:\path\to\ffmpeg.exe" -reencode $false
```
Mind that you can omit -ffmpegPath parameter if you have `ffmpeg.exe` mapped in you Path variable.

## Hardware Acceleration and Encoding
### Hardware Acceleration Options

The script supports hardware acceleration if compatible hardware and drivers are available:

- Intel QuickSync: Ideal for Intel CPUs with integrated graphics supporting QuickSync. Provides efficient H.265 encoding.
- AMD AMF: Suitable for systems with AMD graphics cards, offering accelerated H.265 encoding.
- None: Disables hardware acceleration. Encoding is done via CPU, which may result in slower encoding times but is universally compatible.

### When to Use Hardware Acceleration

Using hardware acceleration (Intel QuickSync or AMD AMF) can speed up the encoding process significantly. However, some trade-offs include:

- Hardware-specific Requirements: QuickSync is available only on certain Intel CPUs, while AMF requires an AMD GPU.
- Potential Quality and Compatibility Differences: Some hardware-accelerated encoders may differ in quality or compatibility compared to software encoding.

### Concatenation Only

The concatenated files produced by the script are viewable even without re-encoding. Re-encoding is optional and is typically done to achieve H.265 compression, which reduces file size while maintaining quality.