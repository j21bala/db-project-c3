@echo off
title Iniciar Proyecto MongoDB CDC
echo ===================================================
echo Iniciando el entorno de migracion a microservicios...
echo ===================================================

REM 1. Asegurar que el script se ejecuta en la carpeta correcta
cd /d "%~dp0"

REM 2. Verificar si Docker esta abierto
echo [1/5] Verificando estado de Docker...
docker info >nul 2>&1
if %errorlevel% equ 0 goto docker_ready

echo Docker no esta corriendo. Iniciando Docker Desktop...
start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"

echo Esperando a que el motor de Docker arranque...
:wait_docker
timeout /t 5 /nobreak >nul
docker info >nul 2>&1
if %errorlevel% neq 0 goto wait_docker

:docker_ready
echo Docker esta listo.

REM 3. Limpiar contenedores y datos corruptos de intentos anteriores
echo [2/5] Limpiando contenedores y datos residuales previos...
docker compose down -v

REM 4. Iniciar los contenedores
echo [3/5] Levantando base de datos, microservicios y middleware...
echo (NOTA: MariaDB esta generando 35,000 datos de prueba, esto toma recursos)
docker compose up -d

REM 5. Esperar un poco a que Nginx este arriba
echo [4/5] Esperando a que el Dashboard este disponible...
timeout /t 8 /nobreak >nul

REM 6. Abrir el dashboard
echo [5/5] Abriendo el Dashboard en el navegador...
start http://localhost:8080

echo ===================================================
echo Entorno iniciado exitosamente! 
echo ===================================================
timeout /t 5 >nul