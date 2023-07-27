#!/bin/bash

# Check if .NET is already installed
if ! command -v dotnet &> /dev/null; then
    echo "Installing .NET Core SDK..."
    # Add your .NET installation commands here based on your system (Linux, macOS, or Windows)
    # For example, on Linux:
    wget https://dotnet.microsoft.com/download/dotnet-script
    chmod +x dotnet-install.sh
    ./dotnet-install.sh -c Current
fi

# Run EF Core database migrations
dotnet ef database update

# Start the ASP.NET Core application
dotnet CtrlLove.dll
