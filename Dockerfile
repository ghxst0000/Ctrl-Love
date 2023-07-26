FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src
COPY ["CtrlLove.csproj", "./"]
RUN dotnet restore "CtrlLove.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "CtrlLove.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CtrlLove.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CtrlLove.dll"]

FROM node:20-alpine3.17 as build
WORKDIR /app
COPY Ctrl-Love-Frontend/Ctrl-Love/package*.json ./
RUN npm ci
COPY Ctrl-Love-Frontend/Ctrl-Love .
RUN npm run build
