#!/bin/bash
# Function to check and install a Darkice and Icecast2 packages

# Add Whiptail information box before installation
whiptail --title "Icecast2 Installation" --msgbox "Icecast2 is about to be installed. During the installation, you will be prompted to enter passwords. Please make sure to remember these passwords as they will be needed later." 12 60

sudo apt-get install -y darkice icecast2

# Copy the pre-configured darkice.cfg file
sudo cp ./configs/darkice.cfg /etc/darkice.cfg

# Ask user about server configuration
if (whiptail --title "Server Configuration" --yesno "The current server in darkice.cfg is set to 'localhost'. Do you want to change it?" 10 60); then
    NEW_SERVER=$(whiptail --inputbox "Enter the new server address:" 8 60 localhost --title "Server Configuration" 3>&1 1>&2 2>&3)
    sudo sed -i "s/server = localhost/server = $NEW_SERVER/" /etc/darkice.cfg
else
    whiptail --title "Server Configuration" --msgbox "Server configuration remains as 'localhost'." 8 60
fi

# Ask user about port configuration
if (whiptail --title "Port Configuration" --yesno "The current port in darkice.cfg is set to '8000'. Do you want to change it?" 10 60); then
    NEW_PORT=$(whiptail --inputbox "Enter the new port number:" 8 60 8000 --title "Port Configuration" 3>&1 1>&2 2>&3)
    sudo sed -i "s/port = 8000/port = $NEW_PORT/" /etc/darkice.cfg
else
    whiptail --title "Port Configuration" --msgbox "Port configuration remains as '8000'." 8 60
fi

# Ask user about mountpoint configuration
if (whiptail --title "Mountpoint Configuration" --yesno "The current mountpoint in darkice.cfg is set to 'stream'. Do you want to change it?" 10 60); then
    NEW_MOUNTPOINT=$(whiptail --inputbox "Enter the new mountpoint:" 8 60 stream --title "Mountpoint Configuration" 3>&1 1>&2 2>&3)
    sudo sed -i "s/mountPoint = stream/mountPoint = $NEW_MOUNTPOINT/" /etc/darkice.cfg
else
    whiptail --title "Mountpoint Configuration" --msgbox "Mountpoint configuration remains as 'stream'." 8 60
fi

# Add Whiptail information box after installation
whiptail --title "Darkice Installation Complete" --msgbox "Darkice has been successfully installed. Configuration will be required next." 10 60

# Ask user for the Icecast2 source password
SOURCE_PASSWORD=$(whiptail --passwordbox "Please enter the source password you set for Icecast2 earlier:" 8 78 --title "Icecast2 Source Password" 3>&1 1>&2 2>&3)

# Update the password in the darkice.cfg file
sudo sed -i "s/password = source password here/password = $SOURCE_PASSWORD/" /etc/darkice.cfg

whiptail --title "Password Updated" --msgbox "The source password has been updated in the darkice.cfg file." 8 60

# Ask user for the stream name
STREAM_NAME=$(whiptail --inputbox "Enter your stream name:" 8 60 "Your Stream Name" --title "Stream Name Configuration" 3>&1 1>&2 2>&3)

# Update the stream name in the darkice.cfg file
sudo sed -i "s/name = your stream name/name = $STREAM_NAME/" /etc/darkice.cfg

whiptail --title "Stream Name Updated" --msgbox "Your stream name has been updated in the darkice.cfg file." 8 60

# Ask user for the domain name
DOMAIN_NAME=$(whiptail --inputbox "Enter your domain name:" 8 60 "example.com" --title "Domain Name Configuration" 3>&1 1>&2 2>&3)

# Construct the full URL
FULL_URL="http://$DOMAIN_NAME:$NEW_PORT/$NEW_MOUNTPOINT"

# Update the URL in the darkice.cfg file
sudo sed -i "s|url = the full url to include domain and :8000 and /stream|url = $FULL_URL|" /etc/darkice.cfg

whiptail --title "URL Updated" --msgbox "Your stream URL has been updated in the darkice.cfg file to: $FULL_URL" 10 60

# Copy the darkice.service file to the systemd directory
sudo cp ./configs/darkice.service /etc/systemd/system/

# Reload the systemd daemon
sudo systemctl daemon-reload

whiptail --title "Darkice Service Setup" --msgbox "The Darkice service file has been copied and the systemd daemon has been reloaded." 8 60

# Enable and start the Darkice service
sudo systemctl enable darkice --now

whiptail --title "Darkice Service Activated" --msgbox "The Darkice service has been enabled and started. Your streaming service is now active." 10 60

# Copy darkice.sh to /home/pi/scripts/
sudo mkdir -p /home/pi/scripts
sudo cp ./configs/darkice.sh /home/pi/scripts/

# Add cron job to restart Darkice daily
(crontab -l 2>/dev/null; echo "3 0 * * * /home/pi/scripts/darkice.sh") | sudo crontab -

whiptail --title "Darkice Daily Restart" --msgbox "A script to restart Darkice has been added to /home/pi/scripts/ and a cron job has been set to run it daily at 3 minutes past midnight." 10 70

# Enable and start the Icecast2 service
sudo systemctl enable icecast2 --now

whiptail --title "Icecast2 Service Activated" --msgbox "The Icecast2 service has been enabled and started. Your streaming server is now active and ready to receive streams." 10 70
