# Stage 1: Build the ASP.NET Backend
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build-dotnet
WORKDIR /src
COPY ["Ctrl-Love-Backend/CtrlLove.csproj", "./"]
RUN dotnet restore "CtrlLove.csproj"
COPY ./Ctrl-Love-Backend .
WORKDIR "/src/"
RUN dotnet build "CtrlLove.csproj" -c Release -o /app/build

# Stage 2: Publish the ASP.NET Backend
FROM build-dotnet AS publish-dotnet
RUN dotnet publish "CtrlLove.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Build the Node.js Frontend
FROM node:20-alpine3.17 AS build-node
WORKDIR /app
COPY Ctrl-Love-Frontend/Ctrl-Love/package*.json ./
RUN npm ci
COPY Ctrl-Love-Frontend/Ctrl-Love .
RUN npm run build

# Stage 4: Final image combining Backend, Frontend, and EF Core Migrations
FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS final
WORKDIR /backend
COPY --from=publish-dotnet /app/publish .
COPY --from=build-node /app/dist ./wwwroot

# Set the working directory for EF Core migrations
WORKDIR /backend


ENTRYPOINT ["dotnet", "CtrlLove.dll"]
# Expose ports for the ASP.NET application
EXPOSE 80
EXPOSE 443