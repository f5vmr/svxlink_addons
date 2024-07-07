#!/bin/bash
### check first if the utilities are installed
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
    mailutils
    mpack
)

# Loop through the packages and install if not already installed
for package in "${packages[@]}"; do
    check_and_install $package
done

echo "All specified packages are installed."
chmod +x install_packages.sh
