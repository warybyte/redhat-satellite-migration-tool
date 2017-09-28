# redhat-satellite-migration-tool
This is a migration tool I wrote in Bash to automate the migration of systems from RHN network (Satellite5) to RHSM network (Satellite6). I found nothing from RedHat to fully automate this process, especially when multiple platforms and activation keys were involved, so I wrote my own. I hope it can help others. 

To make the user credentials easy I created a seperate migration account on both my Satellite5 and Satellite6 servers. 

The logic I use to determine platform is based on the uname results I pull from a system. el5 is considered RH5 and el6 is considered RH6. 

The logic I use to determine activation key is based on a DEV, TEST, and PROD environments, all with corresponding naming conventions.

You'll need Expect (obviously) to run the expect portions of the script. I'm sure there may be other tools, but Expect is what I know best. Outside that most of the commands are based on REDHAT tools or common OS commands.
