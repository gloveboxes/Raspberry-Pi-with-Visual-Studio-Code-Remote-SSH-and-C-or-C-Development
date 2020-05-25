@echo OFF

setlocal

echo(
echo Purpose: This utility creates an SSH key pair, copies the public key to the Raspberry Pi, and updates the OpenSSH config file.
echo Platform: Windows 7, 8, and 10.
echo Version: 1.0, September 2019
echo Author: Dave Glover, http://github.com/gloveboxes
echo Licemce: MIT. Free to use, modify, no liability accepted
echo(
echo(

for /f "tokens=4-8 delims=[.] " %%i in ('ver') do @(if %%i==Version (set version=%%j.%%k& set build=%%l) else (set version=%%i.%%j& set build=%%k))

set usegit="false"

where ssh-keygen /Q

if ERRORLEVEL 1 (

  rem https://www.tenforums.com/tutorials/23975-find-windows-10-build-number.html

  if %version% GEQ 10 if %build% GEQ 17134 (
	echo(
	echo ===========================================================
	echo ERROR: NO SSH SUPPORT FOUND
	echo Version of Windows 10 1803 or better is installed
	echo Install OpenSSH Client https://docs.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse
	echo Install: From Windows 10 Settings, Search Manage optional features, Add OpenSSH Client
	echo ===========================================================
  ) else (
    where git /Q

    if ERRORLEVEL 1 (
		echo(
		echo ======================================================================================
		echo ERROR: NO SSH SUPPORT FOUND
		echo Version of Windows installed is older than Windows 10 1803.
		echo Install Git Client from https://git-scm.com/download/win and rerun the windows-ssh.cmd
		echo ======================================================================================
		echo(
    ) else (
		set usegit="true"
		GOTO :start
    )
  )

  goto :exit

)

:start
    echo(
    set /P c="Enter Raspberry Pi Network IP Address: "
    set PYLAB_IPADDRESS=%c%
    set /P c="Enter your login name: "
    set PYLAB_LOGIN=%c%

    echo(

    if %version% GEQ 10 if %build% GEQ 16257 (
		set /P c="Raspberry Pi Network Address [101;93m%PYLAB_IPADDRESS%[0m, login name [101;93m%PYLAB_LOGIN%[0m. Correct? ([Y]es,[N]o,[Q]uit): "
    ) else (
		set /P c="Raspberry Pi Network entered was '%PYLAB_IPADDRESS%', login name '%PYLAB_LOGIN%'.  Correct? ([Y]es/[N]o): "
    )

    if /I "%c%" EQU "Y" goto :updateconfig
    if /I "%c%" EQU "N" goto :start
	
    echo (
    echo Rerun windows-ssh.cmd
	
    goto :exit

:updateconfig

    set PATHOFIDENTITYFILE=%USERPROFILE%\.ssh\id_rsa_python_lab
	rem Next command does not work inside a conditional block
	for /F "tokens=* USEBACKQ" %%F in (`where git`) do ( set gitpath=%%F ) 2>nul

    if not exist %USERPROFILE%\.ssh\NUL mkdir %USERPROFILE%\.ssh
	
	if not exist %PATHOFIDENTITYFILE%.pub (
		echo(
		echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		echo Generating SSH Key file %USERPROFILE%\.ssh\id_rsa_python_lab
		echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		echo(

		if %usegit% == "true" (
		  echo Generating SSH Key with Git SSH
		  "%gitpath:~0,-13%\git-bash.exe" -c "ssh-keygen -t rsa -N '' -b 4096 -f ~/.ssh/id_rsa_python_lab"
		) else (
		  echo Generating SSH Key Windows SSH Client
		  ssh-keygen -t rsa -b 4096 -N "" -f %USERPROFILE%\.ssh\id_rsa_python_lab
		)	
	)

    set /p PYLAB_KEY=<%USERPROFILE%\.ssh\id_rsa_python_lab.pub
	set REMOTEHOST=%PYLAB_LOGIN%@%PYLAB_IPADDRESS%

    echo(
    echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    echo Copying SSH Public Key to the Raspberry Pi
    echo(

    rem https://gist.github.com/mlocati/fdabcaeb8071d5c75a2d51712db24011
    if %version% GEQ 10 if %build% GEQ 16257 (
		echo [101;93mAccept continue connecting: type yes[0m
		echo [101;93mThe Raspberry Pi Password is raspberry[0m
		echo(
		echo [101;93mThe password will NOT display as you type it[0m
		echo(
		echo [101;93mWhen you have typed the password press ENTER[0m
		echo [101;93mYou may need to press ENTER TWICE[0m
    ) else (      
		echo Accept continue connecting: type yes
		echo The Raspberry Pi Password is raspberry
		echo(
		echo The password will NOT display as you type it
		echo(
		echo When you have typed the password press ENTER
		echo You may need to press ENTER TWICE
    )
	
    echo ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    echo(
	
	setlocal enabledelayedexpansion

    if %usegit% == "true" (
		"%gitpath:~0,-13%\git-bash.exe" -c "ssh %REMOTEHOST% 'mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo %PYLAB_KEY% >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'"
    ) else (
		ssh %REMOTEHOST% "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo '%PYLAB_KEY%' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys" 
	)	
	
	set error=!errorlevel!
    set PYLAB_SSHCONFIG=%USERPROFILE%\.ssh\config

    if %error% EQU 0 (
		echo(
		echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		echo Updating SSH Config file %USERPROFILE%\.ssh\config
		echo +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		echo(

		echo( >> %PYLAB_SSHCONFIG%
		echo #Begin-PyLab %DATE% >> %PYLAB_SSHCONFIG%
		echo Host pylab-%PYLAB_LOGIN% >> %PYLAB_SSHCONFIG%
		echo     HostName %PYLAB_IPADDRESS% >> %PYLAB_SSHCONFIG%
		echo     User %PYLAB_LOGIN% >> %PYLAB_SSHCONFIG%
		echo     IdentityFile ~/.ssh/id_rsa_python_lab >> %PYLAB_SSHCONFIG%
		echo #End-PyLab >> %PYLAB_SSHCONFIG%
		echo( >> %PYLAB_SSHCONFIG%
		
		if %version% GEQ 10 if %build% GEQ 16257 (
			echo [101;93mSuccessfully created, copied SSH Key to Raspberry Pi, and set up %USERPROFILE%\.ssh\config[0m
		) else (		
			echo Successfully created, copied SSH Key to Raspberry Pi, and set up %USERPROFILE%\.ssh\config
		)	
	) else (	
		echo(
	
		if %version% GEQ 10 if %build% GEQ 16257 (
			echo [101;93mThe SSH Public key was NOT copyied to the Raspberry Pi.[0m
			echo [101;93mCheck Raspberry Pi Network address and password and try again.[0m
		) else (
			echo The SSH Public key was NOT copyied to the Raspberry Pi.
			echo Check Raspberry Pi Network address and password and try again.		  
		)		
	)

:exit

    echo(
    echo Finished
    echo(
	
	endlocal

pause