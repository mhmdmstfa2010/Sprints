#!/bin/bash
#
#
#Bash script that automates log file management
#by copying the contents of the /var/log/messages file
#to a new file named /var/log/messages.old. Subsequently

#Define the log and backup files

Log_File=/var/log/messages
Backup_File=/var/log/messages.old

#check if the log file exist

if [ ! -f $Log_File ]
then  
	echo "Log file does not exist here $Log_File."
exit 1
fi

#copy the log file to the backup file

cp $Log_File $Backup_File
if [ $? -eq 0 ]
then
 	echo "Log file copied to $Bachup_file"
else 
	echo "Failed to copy $Log_file to $Backup_File ."
	exit 1
fi 

#clear original file content

truncate -s 0 $Log_File 
if [ $? -ne 0 ]
then
	echo "Failed to clear content of $Log_File ."
	exit 1
fi
echo " Log file cleared successfully!"
exit 0
	
