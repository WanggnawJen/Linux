
#!/bin/bash

clear

echo " "
echo "................................................[ Warning ].........................................."
echo " "
echo "This script should be used only to setup SNMP service for the first time in FreeBSD."
echo "Re-running the script could overwrite the existing settings/configuration of SNMP service."
echo " "
echo "........................................................................................................."
echo " "

echo " "
echo "Checking for any running SNMP service listening..............................................."
ss161=$(netstat -an | grep *.161 | wc -l | tr -d " ")
if [ $ss161 -gt 0 ]; then
	echo " "
	echo " "
	echo '====> SNMP service is already running in the system. Please kill the service and remove them first.'
	echo '====> Otherwise, the installation and SNMP service may conflict !'
	echo " "
	echo " "
	echo "...................................................................................................."
	echo " "
	echo " "
else
	echo " "
	echo " "
	echo "No running SNMP service found."
	echo " "
	echo " "
fi

#--------------------------------------------------------------------------------------------------
#--------------------------------------------------------------------------------------------------

read -p "Do you want to continue running the script to setup SNMP service ? [ yes / no ] : "  run1
if [ "$run1" == "yes"  -o   "$run1" == "y" ]
then

echo " "
service bsnmpd onedisable >  /dev/null  2>&1
service bsnmpd onestop >  /dev/null  2>&1

export ASSUME_ALWAYS_YES=yes

echo " "
echo " "
pkg  install net-snmp  <<  EOF
y
EOF

echo " "
echo "Package installation done.........."
echo " "

#----------------------------------------------------------------------------------------------------


if [ -f  /etc/snmpd.config ]
then
        echo "Checking Another version of SNMP config existing.............................."
	mv  /etc/snmpd.config   /etc/snmpd.config.another
	if [ ! -f  /etc/snmpd.config ];then
	echo " "
	echo "The another SNMP config file (/etc/snmpd.config) has been moved out."
	echo " "
	fi
else
	echo " "
        echo "Another version of SNMP config not found and clear......................................."
	echo " "
fi


#-----------------------------------------------------------------------------------------------------


sc1=$(grep  -e  '^snmpd_enable="YES"' /etc/rc.conf | wc -l | tr -d " ")
if [ "$sc1" ==  1 ]
then 
	echo " "
	echo "Setting found -- $(grep -e '^snmpd_enable="YES"'  /etc/rc.conf)  in  /etc/rc.conf" 
	echo " "
else
	echo " "
	echo "Setting Not found -- adding ( snmpd_enable="YES" )  to /etc/rc.conf........................"
	echo 'snmpd_enable="YES"' >>  /etc/rc.conf
	echo "[Done]......................................................................................"
	echo " "
fi

sc2=$(grep  -e  '^snmpd_flags="-a -r"'  /etc/rc.conf | wc -l | tr -d " ")
if [ "$sc2" ==  1 ]
then
	echo " "
        echo "Setting found -- $(grep -e '^snmpd_flags="-a -r"'  /etc/rc.conf)  in  /etc/rc.conf"
	echo " "
else
	echo " "
        echo "Setting Not found -- adding ( snmpd_flags="-a -r" )  to /etc/rc.conf........................"
        echo 'snmpd_flags="-a -r"' >>  /etc/rc.conf
        echo "[Done]......................................................................................"
	echo " "
fi

sc3=$(grep  -e  '^snmpd_conffile="/usr/local/etc/snmpd.conf"'  /etc/rc.conf | wc -l | tr -d " ")
if [ "$sc3" ==  1 ]
then
	echo " "
        echo "Setting found -- $(grep -e '^snmpd_conffile="/usr/local/etc/snmpd.conf"'  /etc/rc.conf)  in  /etc/rc.conf"
	echo " "
else
	echo " "
        echo "Setting Not found -- adding ( snmpd_conffile="/usr/local/etc/snmpd.conf" )  to /etc/rc.conf........................"
        echo 'snmpd_conffile="/usr/local/etc/snmpd.conf"' >>  /etc/rc.conf
        echo "[Done]............................................................................................................."
	echo " "
fi


#------------------------------------------------------------------------------------------------------

echo " "
if [ -f  /usr/local/share/snmp/snmpd.conf.example ]; then
	cp  /usr/local/share/snmp/snmpd.conf.example   /usr/local/etc/snmpd.conf
	if [ -f  /usr/local/etc/snmpd.conf ]; then
		echo "New SNMP configuration file created in  ( /usr/local/etc/snmpd.conf )"
		sed -i ''  -e  's/agentAddress/#agentAddress/g'  /usr/local/etc/snmpd.conf
		echo agentAddress tcp:161,tcp6:[::1]:161,udp:161  >>  /usr/local/etc/snmpd.conf
		echo "Configuration Modified to -- 'agentAddress tcp:161,tcp6:[::1]:161,udp:161'  in ( /usr/local/etc/snmpd.conf )"
		echo " "
	else
		echo "File not able to create or find in   ( /usr/local/etc/snmpd.conf ) ...........  Permission or File system issues"
		exit
	fi
else	
	echo " "
	echo "SNMP default configuration file ( /usr/local/share/snmp/snmpd.conf.example ) not found !!!   Software package installation error."
	echo " "
	exit
fi

#----------------------------------------------------------------------------------------------------------

read -p 'Do you want to create a SNMP v3 user now  [ yes / no ] ? : '  ans1

if [ "$ans1" == "yes" -o  "$ans1" == "y" ]
then

service  snmpd  stop   >  /dev/null    2>&1

while [ $ans1 == "yes"  -o  $ans1 == "y" ]
do
	echo " "
	echo " "
	echo " "
	echo "Preparing to create SNMP v3 user account now........................................................................"
	echo " "
	echo " "
	read -p "Enter SNMP v3 Username to create  [ no special character ] : "  snmpusername
	read -p "Enter SNMP v3 Authentication password  [ minimum 8 characters ] : "  snmpauth
	read -p "Enter SNMP v3 Encryption password  [ minimum 8 characters ] : " snmpencrypt
	echo " "
	if [ "$snmpusername" != ""  -o   "$snmpauth" != ""  -o  "$snmpencrypt" != "" ]
	then
		net-snmp-config  --create-snmpv3-user  -ro  -a SHA  -A $snmpauth  -x AES -X $snmpencrypt   $snmpusername
		echo " "
		echo "A new SNMP v3 credential has been created with the following to access SNMP data OID."
		echo "..............................................."
		echo "Username= $snmpusername"
		echo "Authentication password= $snmpauth"
		echo "Encryption password= $snmpencrypt" 
		echo "..............................................."
		echo " "
	else
		echo "Your provided value included Empty data. User account could not be created for now."
		echo " "
	fi
	ans1=""
	read -p 'Do you want to create another SNMP v3 user  [ yes / no ] ? : '  ans1
done  

echo " "
service snmpd start   >  /dev/null    2>&1

else

echo " "
echo " "
echo '............................................NO USER CREATED FOR NOW !.....................................................'
echo ' '
echo ' '
echo 'If you want to create SNMP v3 user for later, run the following commands.'
echo '  '
echo '=====>    service  snmpd  stop'
echo '=====>    net-snmp-config  --create-snmpv3-user  -ro  -a SHA  -A Auth_Password  -x AES -X Encrypt_Password  SNMP_Username'
echo '=====>    service  snmpd  start'
echo '  '
echo '...........................................................................................................................'
fi

echo " "
service snmpd enable      >  /dev/null    2>&1

#--------------------------------------------------------------------------------------------------------------

echo " "
echo " "
echo "Checking SNMP Service is listening..............."
css161=$(netstat -an | grep *.161 | wc -l | tr -d " ")
if [ $css161 -gt 0 ]; then
	echo " "
	echo "SNMP Service is running on Port 161 ..............................."
	echo " "
	echo "-------------------------------------------------------------------------------------------------------"
	echo "$(netstat -an | grep *.161)" 
	echo "-------------------------------------------------------------------------------------------------------"
	echo " "
else
	echo " "
	echo "No SNMP Service is running, Please check and repair manually ...................!!!"
	echo " "
fi

#------------------------------------------------------------------------------------------------------------------

echo " "
echo "Completed setting up for SNMP service........................................................................"
echo " "
echo "[ It is recommended to have at least one SNMP v3 user account. If you have created one already, just ignore me. ]"
echo " "
echo " "

#------------------------------------------------------------------------------------------------------------------

echo " "
echo "..........................................................................................................................."
echo " "
echo "To test SNMP OID data collecting, run the following command from another host................"
echo " "
echo "===>  snmpwalk  -v3  -l authPriv  -u SNMP_USERNAME  -a SHA  -A 'SNMP_AUTH_PASSWORD'  -x AES  -X 'SNMP_ENCRYPT_PASSWORD'   THIS_HOST_IP"
echo " "
echo " "

#------------------------------------------------------------------------------------------------------------------------


else
	echo " "
	echo " "
	echo " "
	echo "No Action Performed. The script will exit now ......................................................"
	echo " "
fi


#----------------------------------------------------------------------------------------------------------------------



