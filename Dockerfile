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

# Install MS Build Tools

RUN Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_buildtools.exe -OutFile vs_buildtools.exe

## Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.

RUN ./vs_buildtools.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.AzureBuildTools --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 --remove Microsoft.VisualStudio.Component.Windows81SDK

## Cleanup

RUN Remove-Item vs_buildtools.exe

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


# Set environment variables to avoid prompts during installation
ENV ChocolateyUseWindowsCompression=false

# Install Chocolatey
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command \
    "Set-ExecutionPolicy Bypass -Scope Process -Force; \
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; \
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# Install Visual Studio Build Tools
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command \
    "Invoke-WebRequest -Uri https://aka.ms/vs/16/release/vs_buildtools.exe -OutFile C:\vs_buildtools.exe; \
    Start-Process -Wait -FilePath C:\vs_buildtools.exe -ArgumentList '--quiet', '--wait', '--norestart', '--add', 'Microsoft.VisualStudio.Workload.AzureBuildTools', '--add', 'Microsoft.VisualStudio.Component.SQL.DataTools'"

# Download vswhere.exe
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command \
    "Invoke-WebRequest -Uri https://github.com/microsoft/vswhere/releases/download/2.8.4/vswhere.exe -OutFile C:\vswhere.exe"


# Install NuGet CLI
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://dist.nuget.org/win-x86-commandline/latest/nuget.exe -OutFile C:\nuget.exe"

# Install Microsoft.Data.Tools.Msbuild using NuGet
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "C:\nuget.exe install Microsoft.Data.Tools.Msbuild -OutputDirectory C:\nuget-packages"

# RUN nuget install Microsoft.Data.Tools.Msbuild

# # Cleanup installer
# RUN powershell -NoProfile -ExecutionPolicy Bypass -Command \
#     Remove-Item -Force ./vs_buildtools.exe

RUN Invoke-WebRequest "https://aka.ms/vs/16/release/vs_community.exe" -OutFile "$env:TEMP\vs_community.exe" -UseBasicParsing
RUN & "$env:TEMP\vs_community.exe" --add Microsoft.VisualStudio.Workload.NetWeb --quiet --wait --norestart --noUpdateInstaller | Out-Default

# msbuild
RUN & 'C:/Program Files (x86)/Microsoft Visual Studio/2019/Community/MSBuild/Current/Bin/MSBuild.exe' /version






