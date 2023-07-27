FROM mcr.microsoft.com/dotnet/sdk:7.0
WORKDIR /app

COPY Ctrl-Love-Backend/. .
RUN dotnet restore CtrlLove.csproj
RUN dotnet build -c Release

COPY Ctrl-Love-Backend .

RUN dotnet tool install --global dotnet-ef --version 7.0.0
ENV PATH="$PATH:/root/.dotnet/tools"

CMD ["dotnet", "ef", "database", "update"]