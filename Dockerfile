FROM mcr.microsoft.com/windows/servercore:ltsc2022

LABEL org.opencontainers.image.authors Anil Nair
LABEL org.opencontainers.image.title Windows Runner Container
LABEL org.opencontainers.image.description This image is a base image for the GitHub Self-Hosted runner for the Windows platform.
LABEL org.opencontainers.image.source https://github.com/anilnair00/windows-runner
LABEL org.opencontainers.image.documentation https://github.com/anilnair00/windows-runner/README.md

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

ARG RUNNER_VERSION=VERSION

# Install latest PowerShell
RUN Invoke-WebRequest -Uri 'https://aka.ms/install-powershell.ps1' -OutFile install-powershell.ps1; ./install-powershell.ps1 -AddToPath

####### Install Chocolatey ###############################3

RUN Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


# Ensure Chocolatey is in PATH
RUN setx /M PATH "%PATH%;C:\ProgramData\chocolatey\bin"

# Install Visual Studio Installer
RUN choco install visualstudio-installer -y

# Install Visual Studio 2022 Build Tools with required components
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command \
    $ErrorActionPreference = 'Stop'; \
    $ProgressPreference = 'SilentlyContinue'; \
    Start-Process -Wait -FilePath "C:\ProgramData\chocolatey\lib\visualstudio-installer\tools\vs_installer.exe" -ArgumentList '--quiet', '--wait', '--norestart', '--nocache', '--installPath', 'C:\BuildTools', '--add', 'Microsoft.VisualStudio.Workload.MSBuildTools', '--add', 'Microsoft.VisualStudio.Component.SQL.DataTools'

# Verify installation
RUN "C:\BuildTools\Common7\Tools\VsDevCmd.bat" -command "vswhere -all"
    
# Install GitHub Runner
RUN Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.292.0/actions-runner-win-x64-2.292.0.zip -OutFile runner.zip
RUN Expand-Archive -Path $pwd/runner.zip -DestinationPath C:/actions-runner

# #Install Chocolatey
# RUN Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# #Install Visual Studio 2022
# RUN choco install visualstudio2019buildtools --package-parameters "--add Microsoft.VisualStudio.Workload.MSBuildTools --add Microsoft.VisualStudio.Component.SQL.DataTools --includeRecommended --includeOptional" -y

ADD entrypoint.ps1 entrypoint.ps1
CMD [ "pwsh", ".\\entrypoint.ps1"]

# ENV RUNNER_VERSION=2.292.0
# ENV RUNNER_NAME=TESTSQL
# ENV RUNNER_REPO=adventure_db
# ENV RUNNER_LABELS=windows

# # escape=`

# # Use the latest Windows Server Core 2019 image.
# FROM mcr.microsoft.com/windows/servercore:ltsc2022

# # Restore the default Windows shell for correct batch processing.
# SHELL ["cmd", "/S", "/C"]



# # Define the entry point for the docker container.
# # This entry point starts the developer command prompt and launches the PowerShell shell.
# ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
