FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 8080

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["MyProject.csproj", "./"]
RUN dotnet restore "./MyProject.csproj"
COPY . .
RUN dotnet build "MyProject.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "MyProject.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "MyProject.dll"]
