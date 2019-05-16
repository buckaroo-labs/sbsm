#!/bin/ksh

# The idea is that after cloning this repository, you 
# rename everything from sbsm.* to YourAppName.*
# and customize whatever this file does. For example, the
# code below runs a Java program named myJavaProgram.

APPNAME=$(basename $0 .sh)
. ./$APPNAME.cfg

[[ -e $LOCKFILE ]] && {
echo ERROR: Lock file detected. Exiting.
exit -1
}
touch $LOCKFILE
#cd $HOME

echo Start at `date` >> $LOGFILE

export CP=.:amqp-client-4.0.2.jar:slf4j-api-1.7.21.jar:slf4j-simple-1.7.22.jar:ojdbc6.jar

java -cp $CP myJavaProgram >> $LOGFILE &
JAVA_PID=$!

#lock file is the manager script's means of signaling this script to terminate
while [[ -f $LOCKFILE ]] ; do

#if the java process has exited, this script should too, removing the lockfile
kill -0 $JAVA_PID || {
echo "Java process has terminated. Deleting lockfile and exiting." >> $LOGFILE
echo Exit at `date` >> $LOGFILE
rm $LOCKFILE
exit -9
}

sleep $SLEEP_INTERVAL
done
   
kill $JAVA_PID
echo Exit at `date` >> $LOGFILE

