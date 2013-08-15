@echo off
setlocal EnableDelayedExpansion 

REM Check if Visual Studio 2005 is installed
set MSVCDIR="C:\Program Files\Microsoft Visual Studio 8\VC\vcvarsall.bat"
if exist %MSVCDIR% (
	goto begin
) 

REM Check if Visual Studio 2008 is installed
set MSVCDIR="C:\Program Files\Microsoft Visual Studio 9.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
	goto begin
)

REM Check if Visual Studio 2010 is installed
set MSVCDIR="C:\Program Files\Microsoft Visual Studio 10.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
	goto begin
)

REM Check if Visual Studio 2012 is installed
set MSVCDIR="C:\Program Files\Microsoft Visual Studio 11.0\VC\vcvarsall.bat"
if exist %MSVCDIR% (
	goto begin
)

echo Warning : Microsoft Visual Studio (2005, 2008, 2010 or 2012) is not installed.
goto end

:begin

REM Setup path to helper bin
set ROOT_DIR="%CD%"
set RM="%CD%\bin\unxutils\rm.exe"
set SEVEN_ZIP="%CD%\bin\7-zip\7za.exe"
set WGET="%CD%\bin\unxutils\wget.exe"
set XIDEL="%CD%\bin\xidel\xidel.exe"

REM Housekeeping
%RM% -rf tmp_*
%RM% -rf third-party
%RM% -rf openssl.tar*
%RM% -rf build_*.txt

REM Add MSVCDIR to environment variable
echo Setting up environment
path %path%;%MSVCDIR%;%CD%\bin\perl\perl\bin\

REM Get download url .
echo Get download url...
%XIDEL% http://www.openssl.org/source/ -e "//pre/font/a/font" > tmp_url
set /p url=<tmp_url

REM Download latest openssl and rename to openssl.tar.gz
echo Downloading latest openssl...
%WGET% "http://www.openssl.org/source/%url%" -O openssl.tar.gz

REM Extract downloaded zip file to tmp_openssl
%SEVEN_ZIP% x openssl.tar.gz -y
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl


mkdir third-party\libopenssl

REM Static Release version
cd tmp_openssl\openssl*
perl Configure VC-WIN32 no-asm --prefix=openssl-release-static
call ms\do_ms.bat
call %MSVCDIR% x86
nmake -f ms/nt.mak
nmake -f ms/nt.mak install

xcopy openssl-release-static %ROOT_DIR%\third-party\libopenssl\openssl-release-static\ /S
cd %ROOT_DIR%
%RM% -rf tmp_openssl
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl

REM DLL Release version
cd tmp_openssl\openssl*
perl Configure VC-WIN32 no-asm --prefix=openssl-release-dll
call ms\do_ms.bat
call %MSVCDIR% x86
nmake -f ms/ntdll.mak
nmake -f ms/ntdll.mak install

xcopy openssl-release-dll %ROOT_DIR%\third-party\libopenssl\openssl-release-dll\ /S
cd %ROOT_DIR%
%RM% -rf tmp_openssl
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl

REM Static Debug version
cd tmp_openssl\openssl*
perl Configure debug-VC-WIN32 no-asm --prefix=openssl-debug-static
call ms\do_ms.bat
call %MSVCDIR% x86
nmake -f ms/nt.mak
nmake -f ms/nt.mak install

xcopy openssl-debug-static %ROOT_DIR%\third-party\libopenssl\openssl-debug-static\ /S
cd %ROOT_DIR%
%RM% -rf tmp_openssl
%SEVEN_ZIP% x openssl.tar -y -otmp_openssl

REM DLL Debug version
cd tmp_openssl\openssl*
perl Configure debug-VC-WIN32 no-asm --prefix=openssl-debug-dll
call ms\do_ms.bat
call %MSVCDIR% x86
nmake -f ms/ntdll.mak
nmake -f ms/ntdll.mak install

xcopy openssl-debug-dll %ROOT_DIR%\third-party\libopenssl\openssl-debug-dll\ /S
cd %ROOT_DIR%

%RM% -rf tmp_*
%RM% -rf openssl.tar*
%RM% -rf build_*.txt

:end
exit /b
 