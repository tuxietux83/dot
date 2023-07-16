#!/usr/bin/bash
set -e # Stop the script on all errors
if [ "$(id -u)" == 0 ] ; then
   echo "Please don't run this script as root"
   exit 1
fi
install="sudo apt install -y"
# install and setup the console font first
$install xfonts-terminus
sudo dpkg-reconfigure -plow console-setup
# install xorg, lightdm, apps and more
$install xorg x11-utlis\ #x11
         lightdm slick-greeter\ #lightdm
         pipewire-audio wireplumber pipewire-pulse pipewire-alsa pavucontrol\ #audio
         xdg-user-dirs\ #xdg user directories
         i3 i3lock-fancy i3status i3-wm\ #i3
         firefox-esr geany thunar thunar-archive-plugin thunar-font-manager thunar-volman\ #apps
         nitrogen yt-dlp mpv exa batcat\ #apps
         xclip libnotify-bin dunst\ #dunst
         picom\ #compositor

sudo systemctl enable lightdm.service #enable lightdm
systemctl --user --now enable wireplumber.service #enable WirePlumber
sudo cp /usr/share/doc/pipewire/examples/ld.so.conf.d/pipewire-jack-*.conf /etc/ld.so.conf.d/
sudo ldconfig
xdg-user-dirs-update #update user directories
