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


FROM ghcr.io/antgrutta/winrunner:latest

LABEL org.opencontainers.image.authors Anthony Grutta
LABEL org.opencontainers.image.title Windows Runner Container
LABEL org.opencontainers.image.description This image uses the base image for the GitHub Self-Hosted runner for the Windows platform and includes extra tools that can be used in Actions.
LABEL org.opencontainers.image.source https://github.com/antgrutta/windows-runner-container
LABEL org.opencontainers.image.documentation https://github.com/antgrutta/windows-runner-container/README.md

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

# Install Scoop

RUN Invoke-WebRequest -Uri get.scoop.sh -OutFile 'install-scoop.ps1'; .\install-scoop.ps1 -RunAsAdmin

# Install various packages and utilities

RUN scoop install git

## Workaround for https://github.com/ScoopInstaller/Scoop/issues/4917

RUN scoop bucket rm main
RUN scoop bucket add main
RUN scoop install azure-cli

# Install MS Build Tools

RUN Invoke-WebRequest -Uri https://aka.ms/vs/17/release/vs_buildtools.exe -OutFile vs_buildtools.exe

## Install Build Tools with the Microsoft.VisualStudio.Workload.AzureBuildTools workload, excluding workloads and components with known issues.

RUN ./vs_buildtools.exe --quiet --wait --norestart --nocache --add Microsoft.VisualStudio.Workload.AzureBuildTools --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 --remove Microsoft.VisualStudio.Component.Windows81SDK

## Cleanup

RUN Remove-Item vs_buildtools.exe


ADD entrypoint.ps1 entrypoint.ps1
CMD [ "pwsh", ".\\entrypoint.ps1"]

ENV RUNNER_VERSION=2.292.0
# ENV RUNNER_NAME=TESTSQL
# ENV RUNNER_REPO=adventure_db
# ENV RUNNER_LABELS=windows
