param(
    [string]$ArduinoRoot = "$env:LOCALAPPDATA/Arduino15/packages/arduino",
    [string]$BuildDir = "$env:TEMP/oscaret-trigger-build",
    [switch]$NoLto
)
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$tool = (Get-ChildItem "$ArduinoRoot/tools/avr-gcc" -Directory | Sort-Object Name | Select-Object -Last 1).FullName + '/bin'
$platform = (Get-ChildItem "$ArduinoRoot/hardware/avr" -Directory | Sort-Object Name | Select-Object -Last 1).FullName
$core = "$platform/cores/arduino"
New-Item -ItemType Directory -Force $BuildDir | Out-Null
$flags = @('-Os', '-g', '-ffunction-sections', '-fdata-sections', '-mmcu=atmega328p',
    '-DF_CPU=16000000L', '-DARDUINO=10819', '-DARDUINO_AVR_UNO', '-DARDUINO_ARCH_AVR',
    "-I$core", "-I$platform/variants/standard", "-I$platform/libraries/SPI/src", "-I$root/arduino/oscaret")
$linkFlags = @('-Os', '-mmcu=atmega328p', '-Wl,--gc-sections')
if (!$NoLto) {
    $flags += '-flto'
    $linkFlags += @('-flto', '-fuse-linker-plugin')
}
$sources = @(Get-ChildItem $core -File | Where-Object { $_.Extension -in '.c', '.cpp', '.S' })
$sources += Get-Item "$root/arduino/oscaret/oscar.cpp", "$root/arduino/oscaret/oscaret.ino"
$objects = @()
foreach ($source in $sources) {
    $object = "$BuildDir/$($source.Name).o"
    $compiler = "$tool/avr-gcc.exe"
    $language = @()
    if ($source.Extension -in '.cpp', '.ino') {
        $compiler = "$tool/avr-g++.exe"
        $language = @('-x', 'c++', '-std=gnu++11', '-fno-exceptions', '-fno-threadsafe-statics')
    }
    & $compiler @flags @language -c $source.FullName -o $object
    if ($LASTEXITCODE -ne 0) { throw "Error compilando $($source.Name)" }
    $objects += $object
}
& "$tool/avr-g++.exe" @linkFlags @objects -lm -o "$BuildDir/oscaret.elf"
if ($LASTEXITCODE -ne 0) { throw 'Error enlazando OSCARET' }
& "$tool/avr-size.exe" -C --mcu=atmega328p "$BuildDir/oscaret.elf"
& "$tool/avr-objcopy.exe" -O ihex -R .eeprom "$BuildDir/oscaret.elf" "$BuildDir/oscaret.hex"
if ($LASTEXITCODE -ne 0) { throw 'Error generando HEX' }
& "$tool/avr-objdump.exe" -d -z -C "$BuildDir/oscaret.elf" | Set-Content "$BuildDir/oscaret.disassembly.txt"
if ($LASTEXITCODE -ne 0) { throw 'Error desensamblando OSCARET' }
Write-Output "Firmware y desensamblado: $BuildDir"
