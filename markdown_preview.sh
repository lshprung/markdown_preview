#!/bin/sh

#Variables
RUN=0

file -E $1 > /dev/null 2>&1

#Check for error in argument
if [ $? -gt 0 ]; then
	echo "Error: missing or incorrect argument. Must be a valid file"
	exit
fi

LAST_MOD=`stat $1 --printf=%Y`

#Initial run
pandoc -f markdown -t pdf -o /tmp/preview.pdf $1
zathura /tmp/preview.pdf &
PID=$(pidof -s zathura)

#Loop until zathura is closed
while [ $RUN -eq 0 ]; do
	if [ `stat $1 --printf=%Y` -gt $LAST_MOD ]; then
		LAST_MOD=`stat $1 --printf=%Y`
		pandoc -f markdown -t pdf -o /tmp/preview.pdf $1
	fi
	sleep 5
	RUN=$(ps --pid $PID; echo $?)
	RUN=$(echo $RUN | rev | cut -c 1)
done
