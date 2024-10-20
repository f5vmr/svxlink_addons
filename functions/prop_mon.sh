#!/bin/bash

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
if ! grep -q "# Hosts to pool" /etc/fetchmailrc; then
    cat << EOF >> /etc/fetchmailrc
#############################################################
# Hosts to pool
#############################################################

# Defaults ==============================================
# Set antispam to -1, since it is far safer to use that together with
# no bouncemail

defaults:
timeout 300
antispam -1
batchlimit 100

poll imap.gmail.com
protocol IMAP
user "******@gmail.com" is svxlink
password "********"
folder 'INBOX'
# fetchlimit 1
fetchall
# keep
ssl
mda "/usr/bin/procmail"
EOF
fi

# Set correct permissions for fetchmailrc
chmod 600 /etc/fetchmailrc