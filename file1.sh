#!/bin/bash
#
#
####### if 
##H= expr 30 + 10
##echo $H
#mynum=200
#if [ $mynum -eq 200 ]
#then 
#clear ;	
#echo  "mynum = 200"
#elif [ $mynum -eq 150 ]
#then 
#echo "mynum = 150"	
#else 
#echo "mynum = $mynum"
#fi
 
######## Exit Code
#pakage=htop
#sudo apt install $pakage >> pakage_install.log
#if [ $? -eq 0 ]
#then
#	echo "the installation of $pakage was successfil"
#	echo "the new command is available here:"
#	which $pakage
#	echo " it run in 5"
#else
#	echo " the installation of $pakage was not successful." >> fail.log
#fi
#sleep 5
#$pakage
#
#
#While 

#num=1
#while [ $num -le 10 ]
#do
#       	echo "$num "
#	num=$(($num +1))
#	sleep 0.5
#done
#  if grep -q "Arch" $var         look if "Arch" exist in $var && q for quit 
#
#      For loop
for num in {1..10}
do 
	echo $num
	sleep 0.5
done


