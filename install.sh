#!/bin/bash

whiptail --title "SvxLink Addons" --msgbox "Welcome to the SvxLink Addons. Press Enter to continue." 10 60

CHOICES=$(whiptail --title "SvxLink Addons" --checklist \
"Select the addons you want to install:" 15 60 3 \
"Streaming" "Install Darkice and Icecast2 Streaming service" OFF \
"PropagationMonitor" "Install Svxlink PropagationMonitor" OFF \
#"VoiceMail" "Install MessageService" OFF \
3>&1 1>&2 2>&3)

# Remove quotes from the result
CHOICES=$(echo $CHOICES | tr -d '"')

# Store selected addons in a string
INSTALLED_ADDONS=""

# Process the selected options
for CHOICE in $CHOICES; do
    case $CHOICE in
        "Streaming")
            ./functions/streaming.sh
            INSTALLED_ADDONS+="Streaming, "
            ;;
        "PropagationMonitor")
            ./functions/prop_mon.sh
            INSTALLED_ADDONS+="Propagation Monitor, "
            ;;
#        "VoiceMail")
#            ./functions/voicemail.sh
#            INSTALLED_ADDONS+="VoiceMail, "
#            ;;
    esac
done

# Remove trailing comma and space
INSTALLED_ADDONS=${INSTALLED_ADDONS%, }

# Display completion message with installed addons
whiptail --title "Installation Complete" --msgbox "The following addons have been installed and are now operational:\n\n$INSTALLED_ADDONS" 12 70whiptail --title "Installation Complete" --msgbox "The selected addons have been installed and are now operational." 10 60done