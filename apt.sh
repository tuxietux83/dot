#!/bin/bash
set -e			# Stop on error
#------- colors start
default=$(tput sgr0)
black=$(tput setaf 0)
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
bold=$(tput bold)
#------- colors end
#------- check user start
if [[ $EUID == 0 ]]; then
    echo "${green}Please dont run as ${red}ROOT${green}!${default}"
    exit 1
fi
#------- check user end
#------- variables start
codename=$(lsb_release -sc | tail -n 1)	# Extracting the codename, eg bookworm
repo="/etc/apt"
repo_file="$repo/sources.list" # Path to sources.list
repo_testing_file="$repo/sources.list.d/debian-testing.list" # Path to Debian-testing list
pin_kernel_file="$repo/preferences.d/pin_kernel" # Path to kernel pin
pin_default_file="$repo/preferences.d/pin_default" # Path to default pin

repo_testing_url="deb http://deb.debian.org/debian testing main non-free contrib" #Debian-testing url
repo_testing_url_src="deb-src http://deb.debian.org/debian testing main non-free contrib" #Debian-testing-src url
pin_kernel="Package: linux-image*\nPin: release a=testing\nPin-Priority: 1000\n" # Kernel pin option
pin_default="Package: *\nPin: release a=$codename\nPin-Priority: 500\n" # Default pin option
pin_testing="Package: *\nPin: release a=testing\nPin-Priority: 1\n" # testing repo pinned to 1
#------- variables end
#------- check for files start
# files to check
files=("$repo_testing_file" "$pin_kernel_file" "$pin_default_file")
#to do
for file in "${files[@]}"; do
    if [[ -f "$file" ]]; then
        echo "${red}$file ${default}-> ${yellow}Removing ${default} ..."
        sudo rm -v $file
    else
        echo "${green}$file ${default}-> ${yellow}Not found!${default}"
    fi
done
read -p "${yellow}To continue press ${default}[${red}Enter${default}]${green}...${default}"
#------- check for files end

#------- apt options start
clear
echo "${yellow}Please select repositories:${default}"
echo "1. ${green}Free${default}"
echo "2. ${red}Non-free${default}"
read -p "${yellow}Select option${default}: " option

case $option in
   1)
      sudo sed -i "s/\(main\).*$/\1/" "$repo_file"
      sudo sed -i '/^deb/s/$/ non-free-firmware/g' "$repo_file"
      echo "${bold}${green}$repo_file ${default}${yellow}has been updated to ${green}Free${default}"
      ;;
   2)
      sudo sed -i "s/\(main\).*$/\1/" "$repo_file"
      sudo sed -i '/^deb/s/$/ non-free-firmware non-free contrib/g' "$repo_file"
      echo "${bold}${red}$repo_file ${default}${yellow}has been updated to ${red}Non-Free${default}"
      ;;
   *)
      echo "${red}Invalid option${default}."
      exit 1
      ;;
esac
#------- apt options end

#------- press enter to continue function
read -p "${yellow}To continue press ${default}[${red}Enter${default}]${green}...${default}"

#------- kernel options start
clear
echo "${yellow}Do you want to have the latest kernel${default}:"
echo "1. ${green}Yes${default}"
echo "2. ${red}No${default}"
read -p "${yellow}Select option${default}: " option

case $option in
   1)
      sudo bash -c "echo \"$repo_testing_url\" > \"$repo_testing_file\""
      sudo bash -c "echo \"$repo_testing_url_src\" >> \"$repo_testing_file\""
      sudo bash -c "echo -e \"$pin_kernel\" > \"$pin_kernel_file\""
      sudo bash -c "echo -e \"$pin_default\" > \"$pin_default_file\""
      sudo bash -c "echo -e \"$pin_testing\" >> \"$pin_default_file\""
      echo "${bold}${green}$repo_testing_file ${default}${yellow}has been added${default}"
      echo "${bold}${green}$pin_kernel_file ${default}${yellow}has been added${default}"
      echo "${bold}${green}$pin_default_file ${default}${yellow}has been added${default}"
      ;;
   2)
      echo "${default}${yellow}Nothing to be done!${default}"
      exit 1
      ;;
   *)
      echo "${red}Invalid option${default}."
      exit 1
      ;;
esac
#------- kernel options end


#debug
cat "$repo_file"
cat "$repo_testing_file"
cat "$pin_kernel_file"
cat "$pin_default_file"
