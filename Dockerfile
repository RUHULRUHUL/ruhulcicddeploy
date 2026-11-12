# syntax=docker/dockerfile:1

# ---- Build stage ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore first so the layer is cached until the csproj changes
COPY ruhulcicddeploy/ruhulcicddeploy.csproj ruhulcicddeploy/
RUN dotnet restore ruhulcicddeploy/ruhulcicddeploy.csproj

COPY ruhulcicddeploy/ ruhulcicddeploy/
RUN dotnet publish ruhulcicddeploy/ruhulcicddeploy.csproj \
    -c Release -o /app/publish --no-restore /p:UseAppHost=false

# ---- Runtime stage ----
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app

ENV ASPNETCORE_URLS=http://+:8080 \
    ASPNETCORE_ENVIRONMENT=Production \
    DOTNET_EnableDiagnostics=0

COPY --from=build /app/publish .

# Built-in non-root user ("app") shipped with .NET 8 images
USER app
EXPOSE 8080

ENTRYPOINT ["dotnet", "ruhulcicddeploy.dll"]