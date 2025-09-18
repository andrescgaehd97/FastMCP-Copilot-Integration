@echo off
REM Script de desarrollo local para Soccer API
echo ========================================
echo    Soccer API - Desarrollo Local
echo ========================================

REM Verificar si Python está instalado
python --version >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: Python no está instalado o no está en PATH
    exit /b 1
)

REM Crear entorno virtual si no existe
if not exist "venv" (
    echo Creando entorno virtual...
    python -m venv venv
)

REM Activar entorno virtual
echo Activando entorno virtual...
call venv\Scripts\activate.bat

REM Instalar dependencias
echo Instalando dependencias...
pip install -r requirements.txt

REM Configurar variables de entorno de ejemplo
echo Configurando variables de entorno de ejemplo...
set API_KEY=your_api_key_here
set BASE_URL=https://api-football-v1.p.rapidapi.com/v3
set API_VERSION=api-football-v1.p.rapidapi.com
set PORT=8000
set DEBUG=true

echo ========================================
echo Variables de entorno configuradas:
echo API_KEY=%API_KEY%
echo BASE_URL=%BASE_URL%
echo API_VERSION=%API_VERSION%
echo PORT=%PORT%
echo DEBUG=%DEBUG%
echo ========================================

echo.
echo Para iniciar la aplicación:
echo python app.py
echo.
echo Para acceder al health check:
echo http://localhost:8000/health
echo ========================================