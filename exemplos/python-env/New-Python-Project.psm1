# This is a Powershell Module.
# You must have pyenv-win installed.
# To install this module, do the following:
# - Run the command $env:PSModulePath -split ';'
# - Check the output, it should be something like this:
#      C:\Users\dlucr\OneDrive\Documents\WindowsPowerShell\Modules
#      C:\Program Files\WindowsPowerShell\Modules
#      C:\windows\system32\WindowsPowerShell\v1.0\Modules
# These are the locations of Powershell modules.
# The first one contains the modules for a single user.
#      Use this if you want this script available for a single user
# The second one contains the modules for all users.
#      Use this if you want this script available for all users
# The third one contains modules installed by Windows. Do not use this one
# There might be other directories. Do not use them as well, as they
#      are supposed to be used by third-party software.
# Once you decided where to install the script, create a folder inside
#      the chosen location, with the name New-Python-Project (the name must match exactly).
#      For example:
#      C:\Program Files\WindowsPowerShell\Modules\New-Python-Project
# Next copy this file inside it (you must have administrator privileges)
# Restart your terminal and you should be good to go!

# How to use:
#      To create a new project named MyProject, with Python version 3.9.6, run:
#      New-Python-Project MyProject 3.9.6
#      This will create a new directory, in the current location, called MyProject.
#           If the directory already exists, the module will exit.
#      Next, the module will try to invoke pyenv shell 3.9.6, to set the current
#           Python version to the one specified, only for this shell session.
#           If the Python version is not installed with pyenv, the module will exit.
#      Next, the module will create a virtual env using the following command inside the new folder:
#           python -m venv .venv
#      The module will also create a requirements.txt and .gitignore files
#      The module will then exit
#      Navigate to the newly created folder, open it (e.g. with VSCode),
#           activate the new environment normally:
#           .\.venv\Scripts\Activate.ps1
function New-Python-Project {
    $projectName = $args[0]
    $pythonVersion = $args[1]
    $currentDirectory = Get-Location
    $projectDirectory = "$currentDirectory\$projectName"

    write-host "=============================" -ForegroundColor DarkGray
    write-host "=  Python project creation  =" -ForegroundColor DarkGray
    write-host "=     by Daniel Lucr�dio    =" -ForegroundColor DarkGray
    write-host "= daniel.lucredio@ufscar.br =" -ForegroundColor DarkGray
    write-host "=============================" -ForegroundColor DarkGray
    write-host

    write-host "Project name: " -NoNewline -ForegroundColor DarkGray
    write-host $projectName -ForegroundColor Cyan
    write-host "Python version: " -NoNewline -ForegroundColor DarkGray
    write-host $pythonVersion -ForegroundColor Green

    write-host

    if (Test-Path -Path $projectDirectory) {
        write-host "Path " -NoNewline -ForegroundColor Red
        write-host $projectDirectory -NoNewLine -ForegroundColor Magenta
        write-host " already exists! Exiting script..." -ForegroundColor Red
    } else {
        write-host "Checking if Python version exists..." -ForegroundColor DarkGray
        $pyenvOutput = pyenv shell $pythonVersion
        if ($pyenvOutput) {
            write-host "Python version " -NoNewline -ForegroundColor Red
            write-host $pythonVersion -NoNewLine -ForegroundColor Magenta
            write-host " not installed! Exiting script..." -ForegroundColor Red
        } else {
            write-host "Creating directory: " -NoNewLine -ForegroundColor DarkGray
            write-host $projectDirectory -ForegroundColor White
            New-Item -ItemType Directory -Path $projectDirectory | Out-Null
        
            write-host "Creating virtual environment..." -ForegroundColor DarkGray
            python -m venv "$projectDirectory\.venv"
        
            write-host "Creating requirements.txt..."
            New-Item  -ItemType File -Path "$projectDirectory\requirements.txt" | Out-Null
        
            write-host "Creating .gitignore..."
            New-Item  -ItemType File -Path "$projectDirectory\.gitignore" -Value ".venv" | Out-Null
        
            write-host
            write-host "Success!" -ForegroundColor Green
        }
    }
}
