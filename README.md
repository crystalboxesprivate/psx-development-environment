# PsyQ SDK with CMake

## Installation + Requirements

1. Install [cmake](https://cmake.org/download/)
2. Get [ninja](https://ninja-build.org/). You can use [chocolatey](https://chocolatey.org/install) to install it: `choco install ninja`
3. Add _[thisfolder]/bin_ to **PATH**
4. Add environment variable **PSYQ_DIR** which points to _this_ directory.
5. Make sure the execution policy allows running unsigned **Powershell** scripts: `set-executionpolicy remotesigned` (Run from admin shell)

## Usage

Configuring the project:
`psxbuild cmake`

Building the cmake project:
`psxbuild build`

Or you can just run `psxbuild` if you want to activate the environment for running the SDK tools.
