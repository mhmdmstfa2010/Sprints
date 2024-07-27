#!/bin/bash
#
#
#Bash script that automates log file management
#by copying the contents of the /var/log/messages file
#to a new file named /var/log/messages.old. Subsequently

#Define the log and backup files
Log_File=/var/log/messages
Backup_File=/var/log/messages.old

# prompt the user for their name, age, and country
read -p "Please enter your name: " Name
read -p "Please enter your age: " Age
read -p "Please enter your country: " Country

# Validate age input
while ! [[ "$Age" =~ ^[0-9]+$ ]] || [ "$Age" -lt 1 ] || [ "$Age" -gt 80 ]; 
do
    echo "Invalid age. Please enter a numeric value between 1 and 80."
    read -p "Please enter your age: " Age
done

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
 	echo "Log file copied to $Backup_File"
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
echo "Log file cleared successfully!"
echo "The user is $Name, he is $Age years old, he is from $Country."
exit 0
	
