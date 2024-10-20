#!/bin/bash
#!/bin/bash

whiptail --title "AppArmor Installation Note" \
--msgbox "If AppArmor appears during the software installation process, please select 'No' to proceed without it." 10 60

# Function to check and install a package
check_and_install() {
    package=$1
    dpkg -l | grep -qw $package || sudo apt-get install -y $package
}

# List of packages to install
packages=(
    fetchmail
    procmail
    msmtp
    msmtp-mta
    mailutils
    mpack
    ca-certificates
)

# Loop through the packages and install if not already installed
for package in "${packages[@]}"; do
    check_and_install $package
done

echo "All specified packages are installed."
sudo cp ./configs/fetchmailrc /etc/fetchmailrc
# Ensure START_DAEMON=yes is set in /etc/default/fetchmail
sed -i '/START_DAEMON=/ c\START_DAEMON=yes' /etc/default/fetchmail || echo "START_DAEMON=yes" >> /etc/default/fetchmail
# Update configurations in /etc/fetchmailrc
sed -i '/^set daemon/c\set daemon 300' /etc/fetchmailrc
sed -i '/^set syslog/c\set syslog' /etc/fetchmailrc
sed -i '/^set postmaster/c\set postmaster root' /etc/fetchmailrc
sed -i '/^set no bouncemail/c\set no bouncemail' /etc/fetchmailrc

# Ensure these lines exist, add if not present
grep -q '^set daemon' /etc/fetchmailrc || echo 'set daemon 300' >> /etc/fetchmailrc
grep -q '^set syslog' /etc/fetchmailrc || echo 'set syslog' >> /etc/fetchmailrc
grep -q '^set postmaster' /etc/fetchmailrc || echo 'set postmaster root' >> /etc/fetchmailrc
grep -q '^set no bouncemail' /etc/fetchmailrc || echo 'set no bouncemail' >> /etc/fetchmailrc
# Check and add configurations to /etc/fetchmailrc if they don't exist


sudo cp /etc/fetchmail.rc /etc/fetchmail.rc.bak

email=$(whiptail --title "gmail Address Input" \
--inputbox "Please enter your full gmail address (e.g., username@gmail.com): for procmail" 10 60 3>&1 1>&2 2>&3)

# Check if the user provided input or cancelled
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "You entered: $email"
else
    echo "Input cancelled."
fi

#!/bin/bash

password=$(whiptail --title "gmail Password Input" \
--passwordbox "Please enter your gmail password:" 10 60 3>&1 1>&2 2>&3)

# Check if the user provided input or cancelled
exitstatus=$?
if [ $exitstatus = 0 ]; then
    echo "Password entered."
    
    # Example of passing the password into the next command
    # Here we are just echoing it, but you can replace this with your desired command
    #echo "Your password is: $password"  # Replace this with your actual command
else
    echo "Password input cancelled."
fi
# Update the email in the /etc/fetchmailrc file
sudo sed -i "s/user \".*@gmail\.com\"/user \"$email\"/" /etc/fetchmailrc

# Update the password in the /etc/fetchmail.rc file
sudo sed -i "s/password \".*\"/password \"$password\"/" /etc/fetchmailrc
# Set correct permissions for fetchmailrc
chmod 600 /etc/fetchmailrc
# Configure Procmail
# located /etc/svxlink/.procmailrc
# Replace the commented LOGFILE line with the new path
# Replace the commented LOGFILE line and insert UMASK=0022 after it
# Replace the commented LOGFILE line, insert UMASK=0022 after it, and replace !root with /dev/null

sudo sed -i \
    -e "/#LOGFILE=\$MAILDIR\/procmail.log/s|#LOGFILE=\$MAILDIR/procmail.log|LOGFILE=/var/log/procmail.log|; a UMASK=0022" \
    -e "s|!root|/dev/null|" /etc/svxlink/.procmailrc

echo "Updated LOGFILE, added UMASK=0022, and replaced !root with /dev/null in /etc/svxlink/.procmailrc"
sudo touch /var/log/procmail.log
cd /var/spool/svxlink/propagation_monitor
sudo mkdir vhfdx
sudo chmod 777 vhfdx
cd vhfdx
sudo mkdir archive
sudo chmod 777 archive
cd /var/spool/svxlink/propagation_monitor
sudo mkdir dxrobot
sudo chmod 777 dxrobot
cd dxrobot
sudo mkdir archive
sudo chmod 777 archive
# configure MSMTP
sudo cp /configs/msmtprc /etc/msmtprc
sudo sed -i "s/user \"******@gmail\.com\"/user \"$email\"/" /etc/msmtprc
sudo sed -i "s/password \".*\"/password \"$password\"/" /etc/msmtprc
sudo sed -i "s/^from .*/from $name/" /etc/msmtprc