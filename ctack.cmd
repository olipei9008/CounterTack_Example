@echo off
setlocal EnableDelayedExpansion
cd /d %~dp0
IF EXIST C:\Example\shutdown_time.txt (
   rem Calculate time for reboot.
   set /p rebootStart=<C:\Example\shutdown_time.txt
   call :MeasureTime !rebootStart! %time: =0%
   del "C:\Example\shutdown_time.txt"
)
IF NOT EXIST C:\Example\count.txt echo 0 > C:\Example\count.txt
set /p count=<C:\Example\count.txt
if /i %count% == 0 (
  rem Start the first reboot and prep results file to hold data
  echo F|xcopy "C:\Example\ctack.cmd" "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\ctack.cmd" /y /b
  echo ^|  ITERATION  ^|      REBOOT      ^|    EXTRACT    ^|   COPY DIR   ^|    DELETE    ^|  ^(all times in centiseconds^) > C:\Example\timer.txt
  echo ---------------------------------------------------------------------------------- >> C:\Example\timer.txt
  set /p i_count=<C:\Example\count.txt
  set /a i_count=i_count+1
  echo !i_count! >C:\Example\count.txt
  echo %time: =0% >C:\Example\shutdown_time.txt
  rem shutdown /r /t 10
  goto:EOF
)
if /i %count% == 5 (
  rem The loop is finished, stop rebooting and remove file from startup.
  Call :UnZipFile "C:\Example\zip_files\" "C:\Example\zip_files.zip"
  Call :CopyZipDirectory "C:\Example\copy_files" "C:\Example\zip_files"
  Call :DeleteCopiedDirectory "C:\Example\copy_files"
  Call :PrintData !count!
  del "C:\Example\count.txt"
  del "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\ctack.cmd"
  goto:EOF
)
rem Unzip, copy, and delete a directory and record the times needed to perform each action.
Call :UnZipFile "C:\Example\zip_files\" "C:\Example\zip_files.zip"
Call :CopyZipDirectory "C:\Example\copy_files" "C:\Example\zip_files"
Call :DeleteCopiedDirectory "C:\Example\copy_files"
Call :PrintData %count%
set /a count=count+1
echo %count% >C:\Example\count.txt
echo %time: =0% >C:\Example\shutdown_time.txt
rem shutdown /r /t 10
goto:EOF

:UnZipFile
REM Unzipping file.
set startTime=%time: =0%
set extractDiff=0
set vbs="%temp%\unzip.vbs"
if exist %vbs% del /f /q %vbs%
>>%vbs% echo Set fso = CreateObject("Scripting.FileSystemObject")
>>%vbs% echo If NOT fso.FolderExists(%1) Then
>>%vbs% echo fso.CreateFolder(%1)
>>%vbs% echo End If
>>%vbs% echo set objShell = CreateObject("Shell.Application")
>>%vbs% echo set FilesInZip=objShell.NameSpace(%2).items
>>%vbs% echo objShell.NameSpace(%1).CopyHere(FilesInZip)
>>%vbs% echo Set fso = Nothing
>>%vbs% echo Set objShell = Nothing
cscript //nologo %vbs%
if exist %vbs% del /f /q %vbs%
set stopTime=%time: =0%
Call :MeasureTime %startTime% %stopTime% "extractDiff"
rem set "%~3=%extractDiff%"
goto:eof

:CopyZipDirectory
REM Creating copy.
set startTime=%time: =0%
set copyDiff=0
xcopy %2 %1 /D /I /S /E
set stopTime=%time: =0%
Call :MeasureTime %startTime% %stopTime% "copyDiff"
rem set "%~3=%copyDiff%"
goto:eof

:DeleteCopiedDirectory
REM Deleting copy.
set startTime=%time: =0%
set deleteDiff=0
rd /s /q %1
set stopTime=%time: =0%
Call :MeasureTime %startTime% %stopTime% "deleteDiff"
rem set "%~2=%deleteDiff%"
goto:eof

:MeasureTime
REM Record Time in Text File
rem Remember start time. Note that we don't look at the date, so this
rem calculation won't work right if the program run spans local midnight.
set t0=%1: =0%
rem Capture the end time before doing anything else
set t=%2: =0%
rem make t0 into a scaler in 100ths of a second, being careful not 
rem to let SET/A misinterpret 08 and 09 as octal
set /a h=1%t0:~0,2%-100
set /a m=1%t0:~3,2%-100
set /a s=1%t0:~6,2%-100
set /a c=1%t0:~9,2%-100
set /a starttime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%
rem make t into a scalar in 100ths of a second
set /a h=1%t:~0,2%-100
set /a m=1%t:~3,2%-100
set /a s=1%t:~6,2%-100
set /a c=1%t:~9,2%-100
set /a endtime = %h% * 360000 + %m% * 6000 + 100 * %s% + %c%
rem runtime in 100ths is now just end - start
set /a runtime = %endtime% - %starttime%
echo %runtime% >> "C:\Example\list.txt"
goto:eof

:PrintData
setlocal ENABLEDELAYEDEXPANSION
rem Print the data output for each iteration
set c=0
set iter=%1
set data1=0
set data2=0
set data3=0
set data4=0
for /f %%a in (C:\Example\list.txt) do (
   set /a c+=1
   set data!c!=%%a%
)
set iter=       %iter%
set data1=              %data1%
set data2=            %data2%   
set data3=          %data3%
set data4=              %data4%                 
echo %iter:~-8% %data1:~-27% %data2:~-45% %data3:~-61% %data4:~-75% >> "C:\Example\timer.txt"
del "C:\Example\list.txt"
goto:EOF
