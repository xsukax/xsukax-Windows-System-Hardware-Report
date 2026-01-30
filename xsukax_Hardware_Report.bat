@echo off
REM ============================================================================
REM xsukax Windows System Hardware Report
REM ============================================================================
REM Created by: xsukax
REM GitHub: https://github.com/xsukax
REM Website: Tech Me Away !!!
REM Description: Comprehensive hardware diagnostic and inventory tool
REM Version: 1.0
REM License: GPL v3.0
REM ============================================================================
REM Compatible with Windows 7, 8, 8.1, 10, 11
REM Requires: PowerShell 2.0+ (included in Windows 7+)
REM ============================================================================

setlocal enabledelayedexpansion

REM ============================================================================
REM Configuration Section
REM ============================================================================

:: Set output directory (default: script location)
if "%~1" neq "" (
    set "OUTPUT_DIR=%~1"
) else (
    set "OUTPUT_DIR=%~dp0"
)

:: Clean up output directory path
if not "%OUTPUT_DIR:~-1%"=="\" set "OUTPUT_DIR=%OUTPUT_DIR%\"

:: Generate timestamp
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set "DATETIME=%%I"
set "TIMESTAMP=%DATETIME:~0,4%-%DATETIME:~4,2%-%DATETIME:~6,2%_%DATETIME:~8,2%%DATETIME:~10,2%"

:: Output file
set "OUTPUT_FILE=%OUTPUT_DIR%xsukax_Hardware_Report_%TIMESTAMP%.txt"

:: Temporary files
set "TEMP_PS=%temp%\xsukax_hwdiag_%RANDOM%.ps1"

:: Check for silent mode
set "SILENT_MODE=0"
if "%~2"=="/silent" set "SILENT_MODE=1"

REM ============================================================================
REM Initialization
REM ============================================================================

if %SILENT_MODE% equ 0 (
    echo.
    echo ============================================================================
    echo                xsukax Windows System Hardware Report
    echo ============================================================================
    echo Created by: xsukax
    echo GitHub: https://github.com/xsukax
    echo.
    echo Generating comprehensive hardware report...
    echo This may take up to 30 seconds...
    echo ============================================================================
    echo.
)

REM ============================================================================
REM Create PowerShell Script Line-by-Line
REM ============================================================================

if exist "%TEMP_PS%" del "%TEMP_PS%"

echo $ErrorActionPreference = 'SilentlyContinue' >> "%TEMP_PS%"
echo $WarningPreference = 'SilentlyContinue' >> "%TEMP_PS%"
echo $ProgressPreference = 'SilentlyContinue' >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo function Format-Section { >> "%TEMP_PS%"
echo     param([string]$Title) >> "%TEMP_PS%"
echo     "`r`n" + ("=" * 78) >> "%TEMP_PS%"
echo     "   $Title" >> "%TEMP_PS%"
echo     ("=" * 78) >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo function Get-Output { >> "%TEMP_PS%"
echo     param([string]$SectionTitle, [scriptblock]$ScriptBlock) >> "%TEMP_PS%"
echo     Format-Section -Title $SectionTitle >> "%TEMP_PS%"
echo     try { ^& $ScriptBlock } catch { "Error retrieving data: $_" } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "SYSTEM METADATA" -ScriptBlock { >> "%TEMP_PS%"
echo     "Computer Name: $env:COMPUTERNAME" >> "%TEMP_PS%"
echo     "Current User: $env:USERNAME" >> "%TEMP_PS%"
echo     "User Domain: $env:USERDOMAIN" >> "%TEMP_PS%"
echo     "Admin Rights: $(if ($IsAdmin) { 'Yes' } else { 'No (some data may be limited)' })" >> "%TEMP_PS%"
echo     "Report Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" >> "%TEMP_PS%"
echo     "Uptime: $([math]::Round(((Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime).TotalHours, 2)) hours" >> "%TEMP_PS%"
echo     $lastBoot = Get-CimInstance -ClassName Win32_OperatingSystem >> "%TEMP_PS%"
echo     "Last Boot: $($lastBoot.LastBootUpTime)" >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     $os = Get-CimInstance -ClassName Win32_OperatingSystem >> "%TEMP_PS%"
echo     "Windows Version: $($os.Caption)" >> "%TEMP_PS%"
echo     "Version: $($os.Version)" >> "%TEMP_PS%"
echo     "Build: $($os.BuildNumber)" >> "%TEMP_PS%"
echo     "Architecture: $($os.OSArchitecture)" >> "%TEMP_PS%"
echo     "Serial Number: $($os.SerialNumber)" >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Last 5 Critical Updates:" >> "%TEMP_PS%"
echo     try { >> "%TEMP_PS%"
echo         $hotfixes = Get-HotFix ^| Where-Object { $_.Description -match 'Security Update' -or $_.Description -match 'Critical' } ^| Sort-Object InstalledOn -Descending ^| Select-Object -First 5 >> "%TEMP_PS%"
echo         if ($hotfixes) { >> "%TEMP_PS%"
echo             $hotfixes ^| Format-Table -AutoSize HotFixID, Description, InstalledBy, InstalledOn ^| Out-String -Width 4096 >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             "  No critical updates found or information not available" >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } catch { "  Updates information not available" } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "MOTHERBOARD & BIOS INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $board = Get-CimInstance -ClassName Win32_BaseBoard >> "%TEMP_PS%"
echo     $bios = Get-CimInstance -ClassName Win32_BIOS >> "%TEMP_PS%"
echo     "Manufacturer: $($board.Manufacturer)" >> "%TEMP_PS%"
echo     "Model: $($board.Product)" >> "%TEMP_PS%"
echo     "Version: $($board.Version)" >> "%TEMP_PS%"
echo     "Serial Number: $($board.SerialNumber)" >> "%TEMP_PS%"
echo     "BIOS Manufacturer: $($bios.Manufacturer)" >> "%TEMP_PS%"
echo     "BIOS Version: $($bios.SMBIOSBIOSVersion)" >> "%TEMP_PS%"
echo     "BIOS Date: $($bios.ReleaseDate.ToString('yyyy-MM-dd'))" >> "%TEMP_PS%"
echo     "BIOS Serial: $($bios.SerialNumber)" >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "PROCESSOR INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $cpu = Get-CimInstance -ClassName Win32_Processor >> "%TEMP_PS%"
echo     "Model: $($cpu.Name)" >> "%TEMP_PS%"
echo     "Manufacturer: $($cpu.Manufacturer)" >> "%TEMP_PS%"
echo     "Architecture: $(switch ($cpu.AddressWidth) { 32 { 'x86' } 64 { 'x64' } default { 'Unknown' } })" >> "%TEMP_PS%"
echo     "Cores: $($cpu.NumberOfCores)" >> "%TEMP_PS%"
echo     "Logical Processors: $($cpu.NumberOfLogicalProcessors)" >> "%TEMP_PS%"
echo     "Current Clock: $([math]::Round($cpu.CurrentClockSpeed, 2)) MHz" >> "%TEMP_PS%"
echo     "Max Clock: $([math]::Round($cpu.MaxClockSpeed, 2)) MHz" >> "%TEMP_PS%"
echo     "L2 Cache: $(if ($cpu.L2CacheSize) { "$($cpu.L2CacheSize) KB" } else { 'N/A' })" >> "%TEMP_PS%"
echo     "L3 Cache: $(if ($cpu.L3CacheSize) { "$($cpu.L3CacheSize) KB" } else { 'N/A' })" >> "%TEMP_PS%"
echo     "Socket: $($cpu.SocketDesignation)" >> "%TEMP_PS%"
echo     "TDP: $(if ($cpu.TDP) { "$($cpu.TDP)W" } else { 'N/A' })" >> "%TEMP_PS%"
echo     "Virtualization: $(if ($cpu.VirtualizationFirmwareEnabled) { 'Enabled' } else { 'Disabled' })" >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "MEMORY INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $totalMemory = 0 >> "%TEMP_PS%"
echo     $memory = Get-CimInstance -ClassName Win32_PhysicalMemory >> "%TEMP_PS%"
echo     $memorySlots = Get-CimInstance -ClassName Win32_PhysicalMemoryArray >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Physical Memory Array:" >> "%TEMP_PS%"
echo     "  Max Capacity: $([math]::Round($memorySlots.MaxCapacity / 1KB, 2)) GB" >> "%TEMP_PS%"
echo     "  Memory Slots: $($memorySlots.MemoryDevices)" >> "%TEMP_PS%"
echo     "  Memory Devices: $($memory.Count)" >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     $i = 1 >> "%TEMP_PS%"
echo     foreach ($module in $memory) { >> "%TEMP_PS%"
echo         "Module $i :" >> "%TEMP_PS%"
echo         "  Capacity: $([math]::Round($module.Capacity / 1GB, 2)) GB" >> "%TEMP_PS%"
echo         "  Speed: $($module.Speed) MHz" >> "%TEMP_PS%"
echo         "  Type: $(switch ($module.MemoryType) { 0 {'Unknown'} 1 {'Other'} 2 {'DRAM'} 3 {'Synchronous DRAM'} 4 {'Cache DRAM'} 5 {'EDO'} 6 {'EDRAM'} 7 {'VRAM'} 8 {'SRAM'} 9 {'RAM'} 10 {'ROM'} 11 {'Flash'} 12 {'EEPROM'} 13 {'FEPROM'} 14 {'EPROM'} 15 {'CDRAM'} 16 {'3DRAM'} 17 {'SDRAM'} 18 {'SGRAM'} 19 {'RDRAM'} 20 {'DDR'} 21 {'DDR2'} 22 {'DDR2 FB-DIMM'} 24 {'DDR3'} 26 {'DDR4'} default {'Unknown'} })" >> "%TEMP_PS%"
echo         "  Form Factor: $(switch ($module.FormFactor) { 0 {'Unknown'} 1 {'Other'} 2 {'SIP'} 3 {'DIP'} 4 {'ZIP'} 5 {'SOJ'} 6 {'Proprietary'} 7 {'SIMM'} 8 {'DIMM'} 9 {'TSOP'} 10 {'PGA'} 11 {'RIMM'} 12 {'SODIMM'} 13 {'SRIMM'} 14 {'SMD'} 15 {'SSMP'} 16 {'QFP'} 17 {'TQFP'} 18 {'SOIC'} 19 {'LCC'} 20 {'PLCC'} 21 {'BGA'} 22 {'FPBGA'} 23 {'LGA'} default {'Unknown'} })" >> "%TEMP_PS%"
echo         "  Manufacturer: $($module.Manufacturer)" >> "%TEMP_PS%"
echo         "  Part Number: $($module.PartNumber)" >> "%TEMP_PS%"
echo         "  Serial Number: $($module.SerialNumber)" >> "%TEMP_PS%"
echo         "  Bank: $($module.BankLabel)" >> "%TEMP_PS%"
echo         "  Slot: $($module.DeviceLocator)" >> "%TEMP_PS%"
echo         $totalMemory += $module.Capacity >> "%TEMP_PS%"
echo         $i++ >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Total Installed: $([math]::Round($totalMemory / 1GB, 2)) GB" >> "%TEMP_PS%"
echo     "Total Available: $([math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)) GB" >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "STORAGE INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $disks = Get-CimInstance -ClassName Win32_DiskDrive >> "%TEMP_PS%"
echo     $logical = Get-CimInstance -ClassName Win32_LogicalDisk >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Physical Drives:" >> "%TEMP_PS%"
echo     foreach ($disk in $disks) { >> "%TEMP_PS%"
echo         "Drive: $($disk.Index) - $($disk.Model.Trim())" >> "%TEMP_PS%"
echo         "  Type: $($disk.MediaType)" >> "%TEMP_PS%"
echo         "  Interface: $($disk.InterfaceType)" >> "%TEMP_PS%"
echo         "  Size: $([math]::Round($disk.Size / 1GB, 2)) GB" >> "%TEMP_PS%"
echo         "  Partitions: $($disk.Partitions)" >> "%TEMP_PS%"
echo         "  Serial: $($disk.SerialNumber)" >> "%TEMP_PS%"
echo         "  Firmware: $($disk.FirmwareRevision)" >> "%TEMP_PS%"
echo         "" >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Partitions and Volumes:" >> "%TEMP_PS%"
echo     foreach ($drive in $logical) { >> "%TEMP_PS%"
echo         if ($drive.DriveType -eq 3) { >> "%TEMP_PS%"
echo             "Drive $($drive.DeviceID):" >> "%TEMP_PS%"
echo             "  Size: $([math]::Round($drive.Size / 1GB, 2)) GB" >> "%TEMP_PS%"
echo             "  Free: $([math]::Round($drive.FreeSpace / 1GB, 2)) GB" >> "%TEMP_PS%"
echo             "  Used: $([math]::Round(($drive.Size - $drive.FreeSpace) / 1GB, 2)) GB" >> "%TEMP_PS%"
echo             "  Used Percent: $([math]::Round((($drive.Size - $drive.FreeSpace) / $drive.Size) * 100, 1))%%" >> "%TEMP_PS%"
echo             "  FS: $($drive.FileSystem)" >> "%TEMP_PS%"
echo             if ($drive.VolumeName) { "  Volume Name: $($drive.VolumeName)" } >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "GRAPHICS INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $gpus = Get-CimInstance -ClassName Win32_VideoController >> "%TEMP_PS%"
echo     $i = 1 >> "%TEMP_PS%"
echo     foreach ($gpu in $gpus) { >> "%TEMP_PS%"
echo         "GPU $i :" >> "%TEMP_PS%"
echo         "  Name: $($gpu.Name)" >> "%TEMP_PS%"
echo         "  Manufacturer: $($gpu.AdapterCompatibility)" >> "%TEMP_PS%"
echo         "  Chipset: $($gpu.VideoProcessor)" >> "%TEMP_PS%"
echo         "  Driver: $($gpu.DriverVersion)" >> "%TEMP_PS%"
echo         "  Date: $($gpu.DriverDate.ToString('yyyy-MM-dd'))" >> "%TEMP_PS%"
echo         "  VRAM: $([math]::Round($gpu.AdapterRAM / 1MB, 2)) MB" >> "%TEMP_PS%"
echo         if ($gpu.CurrentHorizontalResolution -and $gpu.CurrentVerticalResolution) { >> "%TEMP_PS%"
echo             "  Current Resolution: $($gpu.CurrentHorizontalResolution)x$($gpu.CurrentVerticalResolution)" >> "%TEMP_PS%"
echo             if ($gpu.CurrentRefreshRate) { "  Refresh Rate: $($gpu.CurrentRefreshRate)Hz" } else { "  Refresh Rate: N/A" } >> "%TEMP_PS%"
echo             if ($gpu.CurrentNumberOfColors) { "  Current Colors: $($gpu.CurrentNumberOfColors)" } else { "  Current Colors: N/A" } >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             "  Current Resolution: N/A (inactive display adapter)" >> "%TEMP_PS%"
echo             "  Refresh Rate: N/A" >> "%TEMP_PS%"
echo             "  Current Colors: N/A" >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo         $i++ >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "NETWORK INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $adapters = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration ^| Where-Object { $_.IPEnabled } >> "%TEMP_PS%"
echo     foreach ($adapter in $adapters) { >> "%TEMP_PS%"
echo         "Adapter: $($adapter.Description)" >> "%TEMP_PS%"
echo         "  MAC Address: $($adapter.MACAddress)" >> "%TEMP_PS%"
echo         "  DHCP Enabled: $($adapter.DHCPEnabled)" >> "%TEMP_PS%"
echo         "  IP Address(es): $($adapter.IPAddress -join ', ')" >> "%TEMP_PS%"
echo         "  Subnet Mask(s): $($adapter.IPSubnet -join ', ')" >> "%TEMP_PS%"
echo         "  Gateway(s): $($adapter.DefaultIPGateway -join ', ')" >> "%TEMP_PS%"
echo         "  DNS Server(s): $($adapter.DNSServerSearchOrder -join ', ')" >> "%TEMP_PS%"
echo         "  DHCP Server: $($adapter.DHCPServer)" >> "%TEMP_PS%"
echo         "" >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "PERIPHERAL DEVICES" -ScriptBlock { >> "%TEMP_PS%"
echo     "USB Devices:" >> "%TEMP_PS%"
echo     try { >> "%TEMP_PS%"
echo         $usbDevices = @() >> "%TEMP_PS%"
echo         Get-CimInstance -ClassName Win32_USBControllerDevice ^| ForEach-Object { >> "%TEMP_PS%"
echo             try { >> "%TEMP_PS%"
echo                 $deviceID = $_.Dependent.DeviceID.Replace('\','\\').Replace('"','\"') >> "%TEMP_PS%"
echo                 $device = Get-CimInstance -ClassName Win32_PnPEntity -Filter "DeviceID='$deviceID'" >> "%TEMP_PS%"
echo                 if ($device -and $device.Name -and $device.Name -notmatch 'USB Root Hub' -and $device.Name -notmatch 'Generic USB Hub' -and $device.Name -notmatch 'Composite Device' -and $device.Name -notmatch 'USB Host Controller') { >> "%TEMP_PS%"
echo                     $usbDevices += $device.Name >> "%TEMP_PS%"
echo                 } >> "%TEMP_PS%"
echo             } catch { } >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo         $uniqueDevices = $usbDevices ^| Select-Object -Unique ^| Sort-Object >> "%TEMP_PS%"
echo         if ($uniqueDevices) { >> "%TEMP_PS%"
echo             $uniqueDevices ^| ForEach-Object { "  - $_" } >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             "  No external USB devices detected" >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } catch { "  USB information not available" } >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Monitors:" >> "%TEMP_PS%"
echo     try { >> "%TEMP_PS%"
echo         $monitors = Get-CimInstance -Namespace root\wmi -ClassName WmiMonitorID -ErrorAction SilentlyContinue >> "%TEMP_PS%"
echo         if ($monitors) { >> "%TEMP_PS%"
echo             $monitorCount = 0 >> "%TEMP_PS%"
echo             foreach ($monitor in $monitors) { >> "%TEMP_PS%"
echo                 try { >> "%TEMP_PS%"
echo                     $name = '' >> "%TEMP_PS%"
echo                     $serial = '' >> "%TEMP_PS%"
echo                     if ($monitor.UserFriendlyName) { >> "%TEMP_PS%"
echo                         $name = -join ($monitor.UserFriendlyName ^| Where-Object { $_ -ne 0 } ^| ForEach-Object { [char]$_ }) >> "%TEMP_PS%"
echo                         $name = $name.Trim() >> "%TEMP_PS%"
echo                     } >> "%TEMP_PS%"
echo                     if ($monitor.SerialNumberID) { >> "%TEMP_PS%"
echo                         $serial = -join ($monitor.SerialNumberID ^| Where-Object { $_ -ne 0 } ^| ForEach-Object { [char]$_ }) >> "%TEMP_PS%"
echo                         $serial = $serial.Trim() >> "%TEMP_PS%"
echo                     } >> "%TEMP_PS%"
echo                     if ($name -or $serial) { >> "%TEMP_PS%"
echo                         $displayName = if ($name) { $name } else { "Unknown Monitor" } >> "%TEMP_PS%"
echo                         $displaySerial = if ($serial) { $serial } else { "N/A" } >> "%TEMP_PS%"
echo                         "  - $displayName (Serial: $displaySerial)" >> "%TEMP_PS%"
echo                         $monitorCount++ >> "%TEMP_PS%"
echo                     } >> "%TEMP_PS%"
echo                 } catch { } >> "%TEMP_PS%"
echo             } >> "%TEMP_PS%"
echo             if ($monitorCount -eq 0) { >> "%TEMP_PS%"
echo                 $fallbackMonitors = Get-CimInstance -ClassName Win32_DesktopMonitor -ErrorAction SilentlyContinue >> "%TEMP_PS%"
echo                 if ($fallbackMonitors) { >> "%TEMP_PS%"
echo                     $fallbackMonitors ^| ForEach-Object { "  - $($_.Name)" } >> "%TEMP_PS%"
echo                 } else { >> "%TEMP_PS%"
echo                     "  Monitor connected but details not available" >> "%TEMP_PS%"
echo                 } >> "%TEMP_PS%"
echo             } >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             $fallbackMonitors = Get-CimInstance -ClassName Win32_DesktopMonitor -ErrorAction SilentlyContinue >> "%TEMP_PS%"
echo             if ($fallbackMonitors) { >> "%TEMP_PS%"
echo                 $fallbackMonitors ^| ForEach-Object { "  - $($_.Name)" } >> "%TEMP_PS%"
echo             } else { >> "%TEMP_PS%"
echo                 "  No monitors detected" >> "%TEMP_PS%"
echo             } >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } catch { "  Monitor information not available" } >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Input Devices:" >> "%TEMP_PS%"
echo     $keyboards = Get-CimInstance -ClassName Win32_Keyboard ^| Select-Object -First 1 >> "%TEMP_PS%"
echo     $mice = Get-CimInstance -ClassName Win32_PointingDevice ^| Select-Object -First 1 >> "%TEMP_PS%"
echo     if ($keyboards) { "  Keyboard: $($keyboards.Name)" } >> "%TEMP_PS%"
echo     if ($mice) { "  Mouse: $($mice.Name)" } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo Get-Output -SectionTitle "POWER INFORMATION" -ScriptBlock { >> "%TEMP_PS%"
echo     $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue >> "%TEMP_PS%"
echo     if ($battery) { >> "%TEMP_PS%"
echo         "Battery Detected: Yes" >> "%TEMP_PS%"
echo         "  Chemistry: $(switch ($battery.Chemistry) { 1 {'Other'} 2 {'Unknown'} 3 {'Lead Acid'} 4 {'Nickel Cadmium'} 5 {'Nickel Metal Hydride'} 6 {'Lithium-ion'} 7 {'Zinc air'} 8 {'Lithium Polymer'} default {'Unknown'} })" >> "%TEMP_PS%"
echo         "  Design Capacity: $(if ($battery.DesignCapacity) { \"$($battery.DesignCapacity) mWh\" } else { 'N/A' })" >> "%TEMP_PS%"
echo         "  Full Charge Capacity: $(if ($battery.FullChargeCapacity) { \"$($battery.FullChargeCapacity) mWh\" } else { 'N/A' })" >> "%TEMP_PS%"
echo         if ($battery.DesignCapacity -and $battery.FullChargeCapacity -and $battery.DesignCapacity -gt 0) { >> "%TEMP_PS%"
echo             "  Health: $([math]::Round(($battery.FullChargeCapacity / $battery.DesignCapacity) * 100, 2))%%" >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             "  Health: N/A" >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo         "  Status: $($battery.Status)" >> "%TEMP_PS%"
echo         "  Estimated Runtime: $(if ($battery.EstimatedRunTime -and $battery.EstimatedRunTime -ne 71582788) { \"$($battery.EstimatedRunTime) minutes\" } else { 'Unknown (plugged in or unavailable)' })" >> "%TEMP_PS%"
echo     } else { >> "%TEMP_PS%"
echo         "Battery Detected: No (Desktop system or battery not present)" >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo     "" >> "%TEMP_PS%"
echo     "Power Supply (if available):" >> "%TEMP_PS%"
echo     try { >> "%TEMP_PS%"
echo         $psu = Get-CimInstance -Namespace root\cimv2\power -ClassName Win32_PowerSupply -ErrorAction SilentlyContinue >> "%TEMP_PS%"
echo         if ($psu) { >> "%TEMP_PS%"
echo             "  Name: $($psu.Name)" >> "%TEMP_PS%"
echo             if ($psu.Manufacturer) { "  Manufacturer: $($psu.Manufacturer)" } >> "%TEMP_PS%"
echo             if ($psu.MaxOutputPower) { "  Max Output: $($psu.MaxOutputPower)W" } else { "  Max Output: N/A" } >> "%TEMP_PS%"
echo         } else { >> "%TEMP_PS%"
echo             "  PSU details not available via standard WMI" >> "%TEMP_PS%"
echo         } >> "%TEMP_PS%"
echo     } catch { "  PSU information not available" } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"
echo. >> "%TEMP_PS%"
echo if ($IsAdmin) { >> "%TEMP_PS%"
echo     Get-Output -SectionTitle "PERFORMANCE METRICS" -ScriptBlock { >> "%TEMP_PS%"
echo         "Note: Performance metrics require admin rights" >> "%TEMP_PS%"
echo         "" >> "%TEMP_PS%"
echo         try { >> "%TEMP_PS%"
echo             $perf = Get-CimInstance -ClassName Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" >> "%TEMP_PS%"
echo             "CPU Usage: $($perf.PercentProcessorTime)%%" >> "%TEMP_PS%"
echo             "Available Memory: $([math]::Round((Get-CimInstance -ClassName Win32_OperatingSystem).FreePhysicalMemory / 1MB, 2)) GB" >> "%TEMP_PS%"
echo         } catch { "Performance counters not accessible" } >> "%TEMP_PS%"
echo     } >> "%TEMP_PS%"
echo } >> "%TEMP_PS%"

REM ============================================================================
REM Execute PowerShell Script
REM ============================================================================

if %SILENT_MODE% equ 0 echo [*] Collecting system data via PowerShell...

powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP_PS%" > "%OUTPUT_FILE%.tmp"

REM ============================================================================
REM Add Header with xsukax Branding
REM ============================================================================

if %SILENT_MODE% equ 0 echo [*] Finalizing report...

(
echo ================================================================================
echo                   xsukax Windows System Hardware Report
echo ================================================================================
echo.
echo Created by    : xsukax
echo GitHub        : https://github.com/xsukax
echo Website       : Tech Me Away !!!
echo License       : GPL v3.0
echo Version       : 1.0
echo.
echo ================================================================================
echo Report Details
echo ================================================================================
echo Generated     : %DATE% %TIME%
echo Computer      : %COMPUTERNAME%
echo User          : %USERNAME%
echo ================================================================================
echo.
echo NOTE: Serial numbers and unique identifiers are displayed for inventory purposes.
echo       Run as administrator for complete hardware details.
echo ================================================================================
echo.
type "%OUTPUT_FILE%.tmp"
echo.
echo ================================================================================
echo                          End of Hardware Report
echo ================================================================================
echo Generated by xsukax Windows System Hardware Report v1.0
echo GitHub: https://github.com/xsukax
echo ================================================================================
) > "%OUTPUT_FILE%"

REM ============================================================================
REM Cleanup and Finalize
REM ============================================================================

if exist "%TEMP_PS%" del "%TEMP_PS%"
if exist "%OUTPUT_FILE%.tmp" del "%OUTPUT_FILE%.tmp"

if %SILENT_MODE% equ 0 (
    echo.
    echo ============================================================================
    echo                      REPORT GENERATION COMPLETE
    echo ============================================================================
    echo.
    echo [+] Report saved to:
    echo     %OUTPUT_FILE%
    echo.
    for %%F in ("%OUTPUT_FILE%") do echo [+] File size: %%~zF bytes
    echo.
    echo [+] To open the report:
    echo     notepad "%OUTPUT_FILE%"
    echo.
    echo ============================================================================
    echo                         Created by xsukax
    echo                    GitHub: https://github.com/xsukax
    echo ============================================================================
    echo.
    pause
)

exit /b 0

REM ============================================================================
REM End of Script
REM ============================================================================
REM xsukax Windows System Hardware Report
REM Licensed under GPL v3.0
REM For issues and updates visit: https://github.com/xsukax
REM ============================================================================