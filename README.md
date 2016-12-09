# ilo-ssh-expect-script
A script to establish automated ssh session with hp iLO via expect tool

This script will try to connect via ssh to ilo management interface and be relatively smart about it.  List of passwords it will try is defined in the script.

It makes a blacklist of invalid passwords,in case you have bunch of ilo machines and e.g. 6 different passphrases and you keep forgetting which is which.

It also saves last valid password to speed up the re-connection.

Script is designed to run under conserver, but it can be easily adapted to be interactive. Uncoment the 'spawn' line in the script to be able to run it by hand, and give it an ip address of ilo management interface as parameter.

A sample conserver config file is attached.



Dropbear ssh client is used due to better compatibility with older iLO instances. Feel free to adapt to another ssh client.
