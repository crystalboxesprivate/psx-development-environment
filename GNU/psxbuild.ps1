$psyq_dir = "$env:PSYQ_DIR".Replace("\", "/")

$env:PSYQ_DIR = $psyq_dir

# CCSPX (supposedly looks for these environment variables)
$env:C_INCLUDE_PATH = "$psyq_dir/PSX/INCLUDE"
$env:C_PLUS_INCLUDE_PATH = "$psyq_dir/PSX/INCLUDE"
$env:COMPILER_PATH = "$psyq_dir/GNU"
$env:G032TMP = "$psyq_dir/TEMP"
$env:GO32 = "DPMISTACK 1000000"
$env:LIBRARY_PATH = "$psyq_dir/PSX/LIB"
$env:PSX_PATH = "$psyq_dir/PSX/BIN"
$env:PSYQ_PATH = "$psyq_dir/GNU"
$env:TMPDIR = "$psyq_dir/TEMP"

Write-Host "Rewriting PSYQ.INI"

$psyq_ini = "[ccpsx]
stdlib=libgs.lib libgte.lib libgpu.lib libspu.lib libsnd.lib libetc.lib libapi.lib libsn.lib libc.lib libcd.lib libcard.lib libmath.lib
compiler_path=$psyq_dir/GNU
assembler_path=$psyq_dir/GNU
linker_path=$psyq_dir/GNU
library_path=$psyq_dir/PSX/LIB
tmpdir=$psyq_dir/TEMP
c_include_path=$psyq_dir/PSX/INCLUDE
cplus_include_path=$psyq_dir/PSX/INCLUDE"

# A configuration file required by ccpsx
Out-File -FilePath "$psyq_dir/GNU/PSYQ.INI" -InputObject $psyq_ini

$option = $args[0]

$currentDir = (Get-Item .).FullName
$buildFolder = "$currentDir/build"

if ($null -eq $option) {
  Write-Host "Initialized"
}
elseif ($option -eq "cmake") {
  New-Item -ItemType Directory -Force -Path $buildFolder
  Push-Location $buildFolder
  & "cmake" ".." "-DCMAKE_TOOLCHAIN_FILE=$psyq_dir/PSX-Toolchain.cmake" "-G" "Ninja"
  Pop-Location
}
elseif ($option -eq "build") {
  Push-Location $buildFolder
  & "cmake" "--build" "."
  Pop-Location
}
else {
  & "ccpsx" $args
}
