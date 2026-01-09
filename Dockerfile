# escape=`

# .NET Framework 4.8 requires Windows containers
# Build stage - uses the SDK image
FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2022 AS build
WORKDIR /src

# Copy NuGet config and packages.config first for layer caching
COPY HelloWorldApp/packages.config HelloWorldApp/
COPY HelloWorldApp.sln .

# Restore NuGet packages
RUN nuget restore HelloWorldApp.sln

# Copy the rest of the source code
COPY HelloWorldApp/ HelloWorldApp/

# Build the application
RUN msbuild HelloWorldApp/HelloWorldApp.csproj /p:Configuration=Release /p:DeployOnBuild=true /p:PublishProfile=FolderProfile /p:OutDir=/app/bin

# Runtime stage - uses the lighter ASP.NET runtime image
FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2022 AS runtime
WORKDIR /inetpub/wwwroot

# Copy published application from build stage
COPY --from=build /app/bin/_PublishedWebsites/HelloWorldApp/ .

# Expose port 80
EXPOSE 80

# The base ASP.NET image automatically configures IIS
# No ENTRYPOINT needed - IIS runs as the default process
