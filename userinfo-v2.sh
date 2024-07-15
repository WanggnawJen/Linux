#!/bin/bash

h1=$(hostname)
v1=$(date +%Y%m%d%H%M%S)


touch  "${h1}_users-info-${v1}.txt"


#Root User list
#---------------
echo "1. Checking Root User..................."
echo "[1. Root User List]"  >>  "${h1}_users-info-${v1}.txt"
echo "(If you don't see any result, root account has been modified / customized.)"  >>  "${h1}_users-info-${v1}.txt"
echo "==========================================================================="   >>  "${h1}_users-info-${v1}.txt"
echo "==========================================================================="   >>  "${h1}_users-info-${v1}.txt"
echo -e "Root-User-Name= $(cat /etc/passwd | grep -e ":0:0:" | cut -d ":" -f 1) \t  Root-UID= $(cat /etc/passwd | grep -e ":0:0:" | cut -d ":" -f 3) \t  Root-GID= $(cat /etc/passwd | grep -e ":0:0:" | cut -d ":" -f 4)"  >>  "${h1}_users-info-${v1}.txt"

echo " "  | tee -a  "${h1}_users-info-${v1}.txt"
echo " "  | tee -a  "${h1}_users-info-${v1}.txt"


#System users list
#------------------
echo "2. Checking System Users......................."
echo "[2. System Users List]"     >>  "${h1}_users-info-${v1}.txt"
echo "======================"   >>  "${h1}_users-info-${v1}.txt"
echo "======================"   >>  "${h1}_users-info-${v1}.txt"
for s1 in $(cat /etc/passwd | grep -v "/bin/bash" | grep -v "/bin/sh" | cut -d ":" -f 1 ); do echo -e "username= $s1\t\t\tuid= $(cat /etc/passwd | grep -e "^$s1:" | cut -d ":" -f 3)\t\t\tgid= $(cat /etc/passwd | grep -e "^$s1:" | cut -d ":" -f 4)"; echo "---------------------------------------------------------------------------------------------------------------------------------"; done  >>  "${h1}_users-info-${v1}.txt"


echo " "  | tee -a  "${h1}_users-info-${v1}.txt"
echo " "  | tee -a  "${h1}_users-info-${v1}.txt"


#Normal users list
#------------------
echo "3. Checking Normal Users......................"
echo "[3. Normal Users List]"   >>  "${h1}_users-info-${v1}.txt"
echo "======================"  >>  "${h1}_users-info-${v1}.txt"
echo "======================"  >>  "${h1}_users-info-${v1}.txt"
for u1 in $(cat /etc/passwd | grep -e ":/bin/bash" -e ":/bin/sh"| grep -v ":0:0:" | cut -d ":" -f 1); do id $u1; echo "----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"; done >>  "${h1}_users-info-${v1}.txt"


echo " "  | tee -a  "${h1}_users-info-${v1}.txt"
echo " "  | tee -a  "${h1}_users-info-${v1}.txt"


#Sudo users
#---------------
echo "4. Checking Privileged Users / Sudo Users........................"
echo "[4. Privileged Users List]"    >>  "${h1}_users-info-${v1}.txt"
echo "=========================="   >>  "${h1}_users-info-${v1}.txt"
echo "=========================="   >>  "${h1}_users-info-${v1}.txt"
echo -e "SUDO_ACCOUNT= $(grep -e "^sudo:" /etc/group | cut -d ":" -f 1) \t\t SUDO_MEMBERS= $(grep -e "^sudo:" /etc/group | cut -d ":" -f 4)"     >>  "${h1}_users-info-${v1}.txt"
echo -e "WHEEL_ACCOUNT= $(grep -e "^wheel:" /etc/group | cut -d ":" -f 1) \t\t WHEEL_MEMBERS= $(grep -e "^wheel:" /etc/group | cut -d ":" -f 4)" >>  "${h1}_users-info-${v1}.txt"
echo -e "ADMIN_ACCOUNT= $(grep -e "^admin:" /etc/group | cut -d ":" -f 1) \t\t ADMIN_MEMBERS= $(grep -e "^admin:" /etc/group | cut -d ":" -f 4)" >>  "${h1}_users-info-${v1}.txt"
echo -e "ROOT_ACCOUNT= $(grep -e "^root:" /etc/group | cut -d ":" -f 1) \t\t ROOT_MEMBERS= $(grep -e "^root:" /etc/group | cut -d ":" -f 4)" >>  "${h1}_users-info-${v1}.txt"


echo " " | tee -a  "${h1}_users-info-${v1}.txt"
echo " " | tee -a  "${h1}_users-info-${v1}.txt"


#Group info
#----------------
echo "5. Checking Group Information......................."
echo "[5. Group Information List]"   >>  "${h1}_users-info-${v1}.txt"
echo "==========================="   >>  "${h1}_users-info-${v1}.txt"
echo "==========================="   >>  "${h1}_users-info-${v1}.txt"
for g1 in $(cat /etc/group | cut -d ":" -f 1 ); do echo -e "group-name= $g1\t\t\tgid= $(cat /etc/group | grep -e "^$g1:" | cut -d ":" -f 3)\t\t\tmembers= $(cat /etc/group | grep -e "^$g1:" | cut -d ":" -f 4)"; echo "-----------------------------------------------------------------------------------------------------------------------"; done   >>  "${h1}_users-info-${v1}.txt"


echo " " | tee -a  "${h1}_users-info-${v1}.txt"
echo " " | tee -a  "${h1}_users-info-${v1}.txt"


#Checking /etc/sudoers file
#---------------------------
echo "6. Checking Sudoers file (To get results in this part, you might need to run this script with root access/privileges !)"
echo "===================================================================================================================="
echo "===================================================================================================================="
echo "[6. Sudo Users or Sudoers which might have Root Privileges or Unlimited Access.......]"    >>  "${h1}_users-info-${v1}.txt"
echo "(If there is no result, you can try run this script with root privileges.............)"  >>  "${h1}_users-info-${v1}.txt"
echo "======================================================================================"  >>  "${h1}_users-info-${v1}.txt"
cat /etc/sudoers |  grep -v "^#" | grep -e "(ALL" | tr -d "%|:|=|(|)|ALL"                                    >>  "${h1}_users-info-${v1}.txt"

echo " "
echo " "


echo "Your file has been created in this current directory:    $(pwd)/"${h1}_users-info-${v1}.txt" "   

echo " "



read -p "Do you want to save the file in another Share/NAS drive using SFTP. Your device must enable for SFTP service and port (TCP/22) for the user.   [Yes/No] ? "   ans1

if [ "$ans1" == "Yes" -o "$ans1" == "Y"  -o  "$ans1" == "y"  -o   "$ans1" == "yes" -o  "$ans1" == "YES" ] ; then
read -p "Enter your login username for connection: " username1
echo " "
read -p "Enter your device's network IP information like [100.123.45.67]:  "  ip1
echo " "
read -p "Enter your shared folder name to store file in device: "   share1
echo " "
echo "You may be asked to enter login password to the device via SFTP."
sftp  $username1@$ip1  << EOF
cd   $share1
put  "${h1}_users-info-${v1}.txt"
ls
exit
EOF

echo "Sending completed. Verify your file has been in the share folder."
echo " "
else
echo "Quitting....."
fi
