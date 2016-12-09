#!/usr/bin/expect -f
#

# automatic ssh session with hp iLO

# debug
# exp_internal 1

set send_slow {1 0.02}

set ilom [lindex $argv 0]

set timeout 5

set mypassword ""

set passphrase ""


#uncomment this for standalone testing
#spawn dbclient admin@$ilom

# initial password list
set passlist [list passphrase1 passphrase2 passphrase3 passphrase4]

# failsafe to make a file it it does not exist
  set failedpassfile [open /etc/conserver/passlist/${ilom}.failedpass.txt a]
  close $failedpassfile


# read in passwords that are known to be invalid

  set failedpassfile [open /etc/conserver/passlist/${ilom}.failedpass.txt r]
  set blacklist [read -nonewline $failedpassfile]
  close $failedpassfile

# if we already have a valid password, use that one
if {[file exists /etc/conserver/passlist/${ilom}.pass.txt]} {
#  puts " -- loading password from file"
  set passwordfile [open /etc/conserver/passlist/${ilom}.pass.txt r]
  set passlist [read -nonewline $passwordfile] 
  close $passwordfile
}


# overwrite the list if we have the password

if { $passphrase != "" } {
#	puts "reusing last valid password";
	set passlist [ list $passphrase ]
} else {
#	puts "no previous valid password found";
}



# open the file with invalid passwords for writing
set failedpassfile [open /etc/conserver/passlist/${ilom}.failedpass.txt a]



# find first password that's not invalid
foreach h $passlist {
	if { [lsearch -exact $blacklist $h] >= 0 } {
		#skip failed password
#		puts "passphrase $h was invalid last time i checked. skipping.";
		continue;
	}
	set mypassword $h
#	puts "i'll try $mypassword"
	break;
}


#	puts "i am trying $mypassword now"
	expect { 
		"Do you want to continue connecting? (y/n)"
		{ 
#			puts "yes";
			send -s "y\r"; sleep 5;
			exit 1;  # it's easiest to exit and next time we won't have this message. less complex this way.
		}
		"admin@"	
		{
			send -s "$mypassword"; sleep 1; send -s "\r"; sleep 20;
		}
	}

expect {
# login failed, because we get another prompt
	"admin@" {
#		puts "marking $mypassword as invalid"
		puts $failedpassfile $mypassword
		close $failedpassfile
		exit 1
	
	}
	"</>hpiLO->" { 
		send -s "vsp" ; sleep 1; send -s "\r" ; sleep 1; 
#		puts "it seems login succeeded; i'll mark $mypassword as valid";
		set passwordfile [open /etc/conserver/passlist/${ilom}.pass.txt w]
		puts $passwordfile $mypassword
		close $passwordfile
	}
}

close $failedpassfile

# we check if the vsp command succeeded

expect {
	"Virtual Serial Port is currently in use by another session." {
#		puts "VSP session is busy. quitting for now";
		exit 2;
	}
	"Virtual Serial Port Active:" {
#		puts "session online";
		send -s "\r";
	}
}


# open session for user
interact
