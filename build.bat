@echo off
setlocal EnableDelayedExpansion 

set PROGFILES=%ProgramFiles%
if not "%ProgramFiles(x86)%" == "" set PROGFILES=%ProgramFiles(x86)%

REM Check if Visual Studio 2013 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 12.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2013"
	goto setup_env
)

REM Check if Visual Studio 2012 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 11.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2012"
	goto setup_env
)

REM Check if Visual Studio 2010 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 10.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2010"
	goto setup_env
)

REM Check if Visual Studio 2008 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 9.0"
if exist %MSVCDIR% (
    set COMPILER_VER="2008"
	goto setup_env
)

REM Check if Visual Studio 2005 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio 8"
if exist %MSVCDIR% (
	set COMPILER_VER="2005"
	goto setup_env
) 

REM Check if Visual Studio 6 is installed
set MSVCDIR="%PROGFILES%\Microsoft Visual Studio\VC98"
if exist %MSVCDIR% (
	set COMPILER_VER="6"
	goto setup_env
) 

echo No compiler : Microsoft Visual Studio (6, 2005, 2008, 2010, 2012 or 2013) is not installed.
goto end

:setup_env

echo Setting up environment
if %COMPILER_VER% == "6" (
	call %MSVCDIR%\Bin\VCVARS32.BAT
	goto begin
)

call %MSVCDIR%\VC\vcvarsall.bat x86

:begin

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
set CP="%CD%\bin\unxutils\cp.exe"
set MKDIR="%CD%\bin\unxutils\mkdir.exe"
set SEVEN_ZIP="%CD%\bin\7-zip\7za.exe"
set WGET="%CD%\bin\unxutils\wget.exe"
set XIDEL="%CD%\bin\xidel\xidel.exe"
path %path%;%CD%\bin\perl\perl\bin\

REM Housekeeping
%RM% -rf tmp_*
%RM% -rf third-party
%RM% -rf openssl.tar*
%RM% -rf build_*.txt

REM Get download url .
echo Get download url...
%XIDEL% http://www.openssl.org/source/ -e "//pre/font/a/font" > tmp_url
set /p url=<tmp_url

REM Download latest openssl and rename to openssl.tar.gz
echo Downloading latest openssl...
%WGET% "http://www.openssl.org/source/%url%" -O openssl.tar.gz

REM Extract downloaded zip file to tmp_openssl
%SEVEN_ZIP% x openssl.tar.gz -y | FIND /V "Igor Pavlov"
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl | FIND /V "ing  " | FIND /V "Igor Pavlov"

REM Static Release version
cd tmp_openssl\openssl*
perl Configure VC-WIN32 no-asm --prefix=openssl-release-static
call ms\do_ms.bat
nmake -f ms/nt.mak
nmake -f ms/nt.mak install

%MKDIR% -p %ROOT_DIR%\third-party\libopenssl\lib\lib-release
%CP% openssl-release-static\lib\*.lib %ROOT_DIR%\third-party\libopenssl\lib\lib-release
%CP% -rf openssl-release-static\include %ROOT_DIR%\third-party\libopenssl

cd %ROOT_DIR%
%RM% -rf tmp_openssl
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl | FIND /V "ing  " | FIND /V "Igor Pavlov"

REM DLL Release version
cd tmp_openssl\openssl*
perl Configure VC-WIN32 no-asm --prefix=openssl-release-dll
call ms\do_ms.bat
nmake -f ms/ntdll.mak
nmake -f ms/ntdll.mak install

%MKDIR% -p %ROOT_DIR%\third-party\libopenssl\lib\dll-release
%CP% openssl-release-dll\lib\*.lib %ROOT_DIR%\third-party\libopenssl\lib\dll-release
%CP% -rf openssl-release-dll\lib\engines %ROOT_DIR%\third-party\libopenssl\lib\dll-release
%CP% openssl-release-dll\bin\*.dll %ROOT_DIR%\third-party\libopenssl\lib\dll-release

cd %ROOT_DIR%
%RM% -rf tmp_openssl
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl | FIND /V "ing  " | FIND /V "Igor Pavlov"

REM Static Debug version
cd tmp_openssl\openssl*
perl Configure debug-VC-WIN32 no-asm --prefix=openssl-debug-static
call ms\do_ms.bat
nmake -f ms/nt.mak
nmake -f ms/nt.mak install

%MKDIR% -p %ROOT_DIR%\third-party\libopenssl\lib\lib-debug
%CP% openssl-debug-static\lib\*.lib %ROOT_DIR%\third-party\libopenssl\lib\lib-debug

cd %ROOT_DIR%
%RM% -rf tmp_openssl

REM DLL Debug version
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl | FIND /V "ing  " | FIND /V "Igor Pavlov"
cd tmp_openssl\openssl*
perl Configure debug-VC-WIN32 no-asm --prefix=openssl-debug-dll
call ms\do_ms.bat
nmake -f ms/ntdll.mak
nmake -f ms/ntdll.mak install

%MKDIR% -p %ROOT_DIR%\third-party\libopenssl\lib\dll-debug
%CP% openssl-debug-dll\lib\*.lib %ROOT_DIR%\third-party\libopenssl\lib\dll-debug
%CP% -rf openssl-debug-dll\lib\engines %ROOT_DIR%\third-party\libopenssl\lib\dll-debug
%CP% openssl-debug-dll\bin\*.dll %ROOT_DIR%\third-party\libopenssl\lib\dll-debug

cd %ROOT_DIR%

%RM% -rf tmp_*
%RM% -rf openssl.tar*
%RM% -rf build_*.txt

:end
exit /b
 