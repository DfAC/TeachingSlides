rem LKB 2011 (C)
rem extract Rinex data  

@ECHO OFF
ECHO ******************
ECHO **START Processing****
ECHO ******************
	echo.
	echo.
	echo.
	
rem Leica
FOR /f %%F IN ('dir /b *.m00') DO (
	ECHO     **Processing Leica %%F...
	rem -R no glonass data -E no Galileo data
	d:\Utils\TEQC\teqc.exe -max_rx_SVs 32 +nav %%~nF.14n,%%~nF.14g +obs %%~nF.14o -leica mdb +rssc %%F
	rem teqc.exe +nav %%~nF.14n,%%~nF.14g +obs %%~nF.14o +R %%F
	rem teqc.exe +nav %%~nF_GPSonly.14n +obs %%~nF_GPSonly.14o -R %%F
)

ECHO QC!
FOR /f %%F IN ('dir /b *.*o') DO (
	ECHO     **Quality Control of RINEX %%F...
	teqc +qc %%F
)

rem del *.proc

	echo.
	echo.
ECHO ******************
ECHO **Processing COMPLETED****
ECHO ******************

PAUSE

,%%~nF.14g



