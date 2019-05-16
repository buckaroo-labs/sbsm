# sbsm
# sophomoric background service manager

This code has its origins in trying to run something like cron on a unix-like system where cron was not available. It evolved into something else, retaining only the secondary functions of being able to start, stop, and bounce a process that 
* runs continuously in the background, 
* should not have more than one running instance, and 
* should maintain some kind of log that the user may wish to follow or tail. 

This code was used most recently for running a java program that dequeued messages from a RabbitMQ server, but it really doesn't matter what the particular application is. 

There are probably better ways to do this, and I don't know if anyone else will find this useful, but I am posting it here mostly to demonstrate that I am not a total n00b with bash scripting.


## The basic parts

### The control file (e.g. sbsm)
This is the file which is run from the command line with one of several command line options to start, bounce, or kill the executable; or to follow its output. This file is pretty much the same for any implementation. One need only copy the file and change the $APPNAME variable at the top to use it for managing a different process. 

### The configuration file (e.g. sbsm.cfg)
This file defines the environment variables shared by the control file and the executable. Typically it has the same name as the control file, with an added ".cfg" suffix. The top several lines - which define the logfile, lockfile, and so forth - are pretty much standard to any implementation. One may also find it convenient to include some of the application logic here, so that the executable file sleeps, reads the config file for changes, and then wakes up with modified instructions. This way new logic can be deployed without interrupting a running process. 

### The executable file (e.g. sbsm.sh)
This file does the actual work. Typically, it has the same name as the control file, with an added ".sh" suffix. Typical behavior is to loop as long as the lockfile defined in the configuration file exists. 

## Files created at runtime (as defined by the config file)
 *   $LOCKFILE is used to control concurrency and provide a means for a graceful exit. If it exists when the executable file is started, the executable will exit right away. If it does not exist when the executable file is started, it will be created. The executable will periodically check that the lockfile still exists, and if it does not, the executable will exit.
 *   $LOGFILE contains the output of the executable. The control file gives the user options to tail or follow $LOGFILE. The control file uses the executable's output to $LOGFILE to know when it has been sucessfully terminated.
