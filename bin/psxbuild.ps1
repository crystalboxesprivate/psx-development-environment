$psyq_dir = "$env:PSYQ_DIR".Replace("\", "/")

$env:PSYQ_DIR = $psyq_dir

# CCSPX (supposedly looks for these environment variables)
$env:C_INCLUDE_PATH = "$psyq_dir/include"
$env:C_PLUS_INCLUDE_PATH = "$psyq_dir/include"
$env:COMPILER_PATH = "$psyq_dir/bin"
$env:G032TMP = "$psyq_dir/temp"
$env:GO32 = "DPMISTACK 1000000"
$env:LIBRARY_PATH = "$psyq_dir/lib"
$env:PSX_PATH = "$psyq_dir/bin"
$env:PSYQ_PATH = "$psyq_dir/bin"
$env:TMPDIR = "$psyq_dir/temp"

Write-Host "Rewriting PSYQ.INI"

$psyq_ini = "[ccpsx]
stdlib=libgs.lib libgte.lib libgpu.lib libspu.lib libsnd.lib libetc.lib libapi.lib libsn.lib libc.lib libcd.lib libcard.lib libmath.lib
compiler_path=$psyq_dir/bin
assembler_path=$psyq_dir/bin
linker_path=$psyq_dir/bin
library_path=$psyq_dir/lib
tmpdir=$psyq_dir/temp
c_include_path=$psyq_dir/include
cplus_include_path=$psyq_dir/include"

# A configuration file required by ccpsx
Out-File -FilePath "$psyq_dir/bin/PSYQ.INI" -InputObject $psyq_ini

$option = $args[0]

$currentDir = (Get-Item .).FullName
$buildFolder = "$currentDir/build"

function Invoke-Build {
  & "cmake" "--build" "."
}

function Invoke-Nopsx {
  $exe_name = $args[1]
  $nopsx_path = 'no$psx/NO$PSX.EXE'
  & "$psyq_dir/tools/$nopsx_path" "$buildFolder/$exe_name.exe"
}

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
  Invoke-Build 
  Pop-Location
}
elseif ($option -eq "run") {
  Push-Location $buildFolder
  Invoke-Nopsx
  Pop-Location
}
elseif ($option -eq "br") {
  Push-Location $buildFolder
  Invoke-Build 
  Invoke-Nopsx
  Pop-Location
}
else {
  & "ccpsx" $args
}
