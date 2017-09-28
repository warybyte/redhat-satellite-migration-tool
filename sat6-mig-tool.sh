#!/bin/bash
# ------------------------------------------
# Redhat RHN to RHSM migration tool
#
# Version:	
# Last Edited: 	September 29, 2017
# Last Editor: 	
# Last Note:	Added pre-check logic
# ------------------------------------------

#
# Here are some variables for platform and key determination
#

	OSPLAT=$(uname -r)
	OSNAME=$(uname -n)

#
# precheck checks...these can be commented out
#
	clear;
	echo "";
	echo "--------------------------------------";
	echo "RHN-to-RHSM MIGRATION PRE-CHECKS";
	echo "--------------------------------------";
	echo ""
	echo "Current registration";
	echo "--------------------------------------";
	/usr/bin/yum repolist;
	echo "--------------------------------------";
	echo ""
	PRECHECK=$(yum repolist | grep "receiving updates from RHN Classic")
	if [[ $PRECHECK == *"RHN"* ]]; then
		echo $PRECHECK "Proceeding with repo migration.";
		sleep 5;
	else
		echo "It appears this device is not registered to RHN. Terminating migration now."
		sleep 5;
		exit 1;
	fi
#
# Pull down RHSM Satellite 6 certificate.
#
	clear;
	echo "Pulling down the new Satellite 6 certificate.";
	/bin/rpm -Uvh http://YOUR.SATELLITE.6.SERVER/pub/katello-ca-consumer-latest.noarch.rpm;				
	echo "";
#
# Install suscription-manager and migration tools
#
	echo "Installing needed software packages for migration";
	/usr/bin/yum install -y subscription-manager-migration subscription-manager-migration-data;
	echo "";
#
# Determine platform and activation key, then register accordingly
#
	echo "Beginning initial migration from RHN network to RHSM";
#
# Outer IF to check for RHEL 6 platform
#
	if [[ $OSPLAT == *"el6"* ]]; then
	#
	# Inner IF is logic to determine environment...assumes production as the safest option if inconclusive.
	#
	if [[ $OSNAME == *"dev"* ]] || [[ $OSNAME == *"OTHER LOGIC AS NEEDED"* ]]; then
		echo "This appears to be a RH6 dev box";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM" --activation-key="RH6-DEV-KEY" --force
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
                        expect { sleep 10 }
			"
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		elif [[ $OSNAME == *"qa"* ]] || [[ $OSNAME == *"OTHER LOGIC AS NEEDED"* ]]; then
			echo "This appears to be a RH6 qa box";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM" --activation-key="RH6-QA-KEY" --force
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
                        expect { sleep 10 }
			"
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		elif [[ $OSNAME == *"prod"* ]] || [[ $OSNAME == *"OTHER LOGIC AS NEEDED"* ]]; then
			echo "This appears to be a RH6 prod box";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM" --activation-key="RH6-PROD-KEY" --force
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect { sleep 10 }
			"
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello agent;
		else
			echo "I know it's a RH6 box, but can't determine environment. Assuming Production.";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM" --activation-key="RH6-PROD-KEY" --force
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
                        expect { sleep 10 }
			"
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		fi
#
# Outer ELIF to check for RHEL 5 platform
#
	elif [[ $OSPLAT == *"el5"* ]]; then
	#
	# Inner IF is logic to determine environment...assumes production as the safest option if inconclusive.
	#
		if [[ $OSNAME == *"dev"* ]] || [[ $OSNAME == *"OTHER LOGIC AS NEEDED"* ]]; then
			echo "This appears to be a RH5 dev box";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM"
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"Environment: \" { send -h \"<ENVIRONMENT>\r\" }
			}
			expect { sleep 10 }
			"
			#
			# Force a re-registration using specific key after migration
			#
			echo "Re-registering with specific activation key from Satellite 6";
			/usr/sbin/subscription-manager register --org="ORGANIZATION.COM" --activationkey="RH5-DEV-KEY" --force;
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		elif [[ $OSNAME == *"qa"* ]] || [[ $OSNAME == *"OTHER LOGIC AS NEEDED"* ]]; then
			echo "This appears to be a RH5 qa box";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM"
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"Environment: \" { send -h \"<ENVIRONMENT>\r\" }
			}
			expect { sleep 10 }
			"
			#
			# Force a re-registration using specific key after migration
			#
			echo "Re-registering with specific activation key from Satellite 6";
			/usr/sbin/subscription-manager register --org="ORGANIZATION.COM" --activationkey="RH5-QA-KEY" --force;
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		elif [[ $OSNAME == *"prod"* ]] || [[ $OSNAME == *"OTHER LOGIC AS NEEDED"* ]]; then
			echo "This appears to be a RH5 prod box";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM"
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"Environment: \" { send -h \"<ENVIRONMENT>\r\" }
			}
			expect { sleep 10 }
			"
			#
			# Force a re-registration using specific key after migration
			#
			echo "Re-registering with specific activation key from Satellite 6";
			/usr/sbin/subscription-manager register --org="ORGANIZATION.COM" --activationkey="RH5-PROD-KEY" --force;
                        /usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		else
			echo "I know it's a RH5 box, but can't determine environment. Assuming Production.";
			expect -c "
			spawn sudo /usr/sbin/rhn-migrate-classic-to-rhsm --org="ORGANIZATION.COM"
			set send_human {.1 .3 1 .05 2}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"username: \" { send -h \"<ENTER USER NAME>\r\" }
			}
			expect {
				\"password: \" { send -h \"<ENTER CREDS>\r\" }
			}
			expect {
				\"Environment: \" { send -h \"<ENVIRONMENT>\r\" }
			}
			expect { sleep 10 }
			"
			#
			# Force a re-registration using specific key after migration
			#
			echo "Re-registering with specific activation key from Satellite 6";
			echo "Re-registering with specific activation key from Satellite 6" >> /var/log/messages;
			/usr/sbin/subscription-manager register --org="ORGANIZATION.COM" --activationkey="RH5-PROD-KEY" --force;
			/usr/bin/yum clean all;
			/usr/bin/yum install -y katello-agent;
		fi
	else # all out of answers...
	echo "OS could not be determined. Please verify OS and register manually.";
fi

