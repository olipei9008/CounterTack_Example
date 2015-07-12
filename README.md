# CounterTack_Example
Test script to demonstrate technical skills to CounterTack.

Instructions are as follows:
-----------------------------

Create a script, program or set of scripts, at any language you feel comfortable, that do the following:


1. Reboots a windows PC, and calculates how much time it takes to reboot
2. Extracts a zip file to a directory, and calculates time it takes to extract
3. Copies the extracted directory, and calculates the time it takes
4. Deletes the directory, and calculates the time it needs
5. Repeats the steps 1-4 5 times, and writes the times to execute in a file

Implementation:
-----------------

The main routine handles restarting the Windows PC and keeps track of the restart count through
a file at "C:\Example\count.txt".  It feeds the count info into this file before each restart 
and pulls the count info from the file after the restart. This routine also calls on subroutines 
to handle the extracting, copying, and deleting.  All of the mentioned routines and subroutines 
call on the :MeasureTime subroutine to measure execution time for the required actions.  The main 
routine also calls on :PrintData to record the results in "C:\Example\timer.txt".

Restart (main routine)
Calling the restart routine on startup in order to fulfill the 5-restart requirement involved 
creating a condition to copy the script into the %appdata% startup folder.  However, this means 
the script only runs on the startup when the specific user's profile loads up, so this requires 
a user to login to function.  Attempts were made to copy the script to the startup folder that 
affects all users, but this requires administrator privileges so this implementation idea was 
scrapped.  Another possibility might have been registry keys, but copying the script into the 
startup folder seemed like an easier solution to implement.

Recording the execution time for each restart involved saving the time at shutdown in a file 
called "C:\Example\shutdown_time.txt".  Then when the script runs at startup, it takes the time 
recorded in the file and calculates the difference from the current time to get the execution time.

:UnZip
This subroutine extracts to a desired folder from a given zip folder.  The main code was taken 
from an online source*.  The source echo'd commands for a vbscript into a .vbs file and then used 
cscript to the run the vbscript from batch.  The vbscript itself performs the extracting process 
by copying the items inside a zip folder to the desired folder.  It records its own startup time 
and end time for use by :MeasureTime.
(*source: http://stackoverflow.com/questions/21704041/creating-batch-script-to-unzip-a-file-without-additional-zip-tools)

:CopyZipDirectory
This subroutine copies from one folder to another folder. It records its own startup time 
and end time for use by :MeasureTime.

:DeleteCopiedDirectory
This subroutine deletes a specified folder.  It records its own startup time 
and end time for use by :MeasureTime.

:MeasureTime
This subroutine calculates the difference between two different times and records the data in a 
file called "list.txt".  It uses code from an online source*.  It calculates the difference by 
extracting the hours, minutes, seconds, and centiseconds from the time given and converts everything 
to centiseconds (1/100 of a second).  It then calculates the difference between the given start time 
and given end time in centiseconds.  
Some differences from the original code include the result is given in centiseconds 
and the resulting data is printed to "C:\Example\list.txt".
(*source:http://curiouser.cheshireeng.com/2014/08/20/trick-timing-a-command-using-a-bat-file/)

:PrintData
This subroutine gets the data from "C:\Example\list.txt" to echo to "C:\Example\timer.txt" in a 
formatted way.  The formatting is sloppy but fits for each "category" and was designed to fit 
the labels printed from the main routine.  It uses a for loop to go through the times listed 
in "C:\Example\list.txt" and works because the times for restarting, unzipping, copying, and deleting 
are always recorded in order.  This code also deletes list.txt afterwards so that a new list 
can be created for each iteration.
