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
# Install GitHub Runner
RUN Invoke-WebRequest -Uri https://github.com/actions/runner/releases/download/v2.292.0/actions-runner-win-x64-2.292.0.zip -OutFile runner.zip
RUN Expand-Archive -Path $pwd/runner.zip -DestinationPath C:/actions-runner
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]
ADD entrypoint.ps1 entrypoint.ps1
CMD [ "pwsh", ".\\entrypoint.ps1"]

# ENV RUNNER_VERSION=2.292.0
# ENV RUNNER_NAME=TESTSQL
# ENV RUNNER_REPO=adventure_db
# ENV RUNNER_LABELS=windows

# escape=`
# Use the latest Windows Server Core 2019 image.
FROM mcr.microsoft.com/windows/servercore:ltsc2022

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]
RUN `
   # Download the Build Tools bootstrapper.
   curl -SL --output vs_buildtools.exe
https://aka.ms/vs/16/release/vs_buildtools.exe
`
   `
   # Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.
&& (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
       --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" `
       --add Microsoft.VisualStudio.Workload.AzureBuildTools `
       --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
       --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
       --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
       --remove Microsoft.VisualStudio.Component.Windows81SDK `
       || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
   `
   # Cleanup
&& del /q vs_buildtools.exe
# Define the entry point for the docker container.
# This entry point starts the developer command prompt and launches the PowerShell shell.
ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2019\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
