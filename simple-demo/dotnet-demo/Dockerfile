# Using Paketo Buildpacks for Cloud Native builds
FROM paketobuildpacks/builder-jammy-base:latest AS builder
WORKDIR /workspace
COPY . .

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app

COPY --from=builder /workspace/bin/Release/net8.0/publish/ .

EXPOSE 8081

ENV ASPNETCORE_URLS=http://+:8081
ENV DOTNET_RUNNING_IN_CONTAINER=true

ENTRYPOINT ["dotnet", "dotnet-demo.dll"]
