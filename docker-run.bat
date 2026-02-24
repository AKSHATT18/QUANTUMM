@echo off
REM QuantumShield Docker Runner Script for Windows
REM This script provides easy commands to manage the QuantumShield Docker environment

setlocal enabledelayedexpansion

REM Check if command is provided
if "%1"=="" goto help

REM Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker is not running. Please start Docker and try again.
    exit /b 1
)

REM Check if Docker Compose is available
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Docker Compose is not available. Please install Docker Compose and try again.
    exit /b 1
)

REM Main script logic
if "%1"=="dev" goto dev
if "%1"=="prod" goto prod
if "%1"=="stop" goto stop
if "%1"=="logs" goto logs
if "%1"=="logs-dev" goto logs-dev
if "%1"=="build" goto build
if "%1"=="clean" goto clean
if "%1"=="status" goto status
if "%1"=="shell" goto shell
if "%1"=="shell-dev" goto shell-dev
if "%1"=="db-shell" goto db-shell
if "%1"=="db-shell-dev" goto db-shell-dev
if "%1"=="health" goto health
if "%1"=="help" goto help
goto unknown

:dev
echo ℹ️  Starting QuantumShield development environment...
docker-compose -f docker-compose.dev.yml up -d
echo ✅ Development environment started!
echo 🌐 Application: http://localhost:5000
echo 🗄️  Database: localhost:5432
echo 🔴 Redis: localhost:6379
echo 📊 pgAdmin: http://localhost:5050 (admin@quantumshield.dev / admin123)
echo 🔍 Redis Commander: http://localhost:8081
echo.
echo ℹ️  View logs with: docker-run.bat logs-dev
goto end

:prod
echo ℹ️  Starting QuantumShield production environment...
docker-compose up -d
echo ✅ Production environment started!
echo 🌐 Application: http://localhost:5000
echo 🗄️  Database: localhost:5432
echo 🔴 Redis: localhost:6379
echo.
echo ℹ️  View logs with: docker-run.bat logs
goto end

:stop
echo ℹ️  Stopping all QuantumShield environments...
docker-compose down
docker-compose -f docker-compose.dev.yml down
echo ✅ All environments stopped!
goto end

:logs
echo ℹ️  Viewing production logs...
docker-compose logs -f app
goto end

:logs-dev
echo ℹ️  Viewing development logs...
docker-compose -f docker-compose.dev.yml logs -f app
goto end

:build
echo ℹ️  Building QuantumShield Docker images...
docker-compose build --no-cache
echo ✅ Build completed!
goto end

:clean
echo ⚠️  This will remove ALL containers, images, and volumes!
set /p confirm="Are you sure? (y/N): "
if /i "!confirm!"=="y" (
    echo ℹ️  Cleaning up Docker resources...
    docker-compose down -v --rmi all
    docker-compose -f docker-compose.dev.yml down -v --rmi all
    docker system prune -f
    echo ✅ Cleanup completed!
) else (
    echo ℹ️  Cleanup cancelled.
)
goto end

:status
echo ℹ️  Container status:
echo Production containers:
docker-compose ps
echo.
echo Development containers:
docker-compose -f docker-compose.dev.yml ps
goto end

:shell
echo ℹ️  Accessing production application container...
docker-compose exec app sh
goto end

:shell-dev
echo ℹ️  Accessing development application container...
docker-compose -f docker-compose.dev.yml exec app sh
goto end

:db-shell
echo ℹ️  Accessing production database...
docker-compose exec postgres psql -U quantumshield -d quantumshield
goto end

:db-shell-dev
echo ℹ️  Accessing development database...
docker-compose -f docker-compose.dev.yml exec postgres psql -U quantumshield -d quantumshield_dev
goto end

:health
echo ℹ️  Checking service health...
echo Application:
curl -s http://localhost:5000/api/health >nul 2>&1
if errorlevel 1 (
    echo ❌ Application is not responding
) else (
    echo ✅ Application is healthy
)

echo Database:
docker-compose exec postgres pg_isready -U quantumshield -d quantumshield >nul 2>&1
if errorlevel 1 (
    echo ❌ Database is not responding
) else (
    echo ✅ Database is healthy
)

echo Redis:
docker-compose exec redis redis-cli ping >nul 2>&1
if errorlevel 1 (
    echo ❌ Redis is not responding
) else (
    echo ✅ Redis is healthy
)
goto end

:help
echo 🚀 QuantumShield Docker Runner Script
echo.
echo Usage: %0 [command]
echo.
echo Commands:
echo   dev         - Start development environment
echo   prod        - Start production environment
echo   stop        - Stop all environments
echo   logs        - View application logs
echo   logs-dev    - View development logs
echo   build       - Build Docker images
echo   clean       - Remove all containers and images
echo   status      - Show container status
echo   shell       - Access application container shell
echo   db-shell    - Access database shell
echo   health      - Check service health
echo   help        - Show this help message
echo.
echo Examples:
echo   %0 dev      - Start development environment
echo   %0 prod     - Start production environment
echo   %0 logs     - View logs
echo.
goto end

:unknown
echo ❌ Unknown command: %1
echo.
echo Use '%0 help' to see available commands.
exit /b 1

:end
exit /b 0
