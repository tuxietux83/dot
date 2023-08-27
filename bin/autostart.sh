#!/usr/bin/bash
#NOTE: Not tested on sway!!
#set -e -u   # Hyprland dont like this on
	export QT_QPA_PLATFORMTHEME=qt5ct
	export QT_PLATFORMTHEME=qt5ct
	export QT_PLATFORM_PLUGIN=qt5ct
	export MOZ_ENABLE_WAYLAND=1
if [ "$DESKTOP_SESSION" = "sway" ]; then
	export XCURSOR_SIZE=32
	export XDG_CURRENT_DESKTOP=sway
	export XDG_SESSION_DESKTOP=sway
	export XDG_SESSION_TYPE=wayland
elif [ "$DESKTOP_SESSION" = "hyprland" ]; then
	export XCURSOR_SIZE=32
	export XDG_CURRENT_DESKTOP=Hyprland
	export XDG_SESSION_DESKTOP=Hyprland
	export XDG_SESSION_TYPE=wayland
fi
dbus-update-activation-environment --systemd --all
# Colors
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
# Update SERVICE function
SERVICE_UPDATE() {
    SERVICE="$SERVICE"
    SERVICE_INFO="[${green} $SERVICE${default} ]"
    HYPR_SERVICE="[ $SERVICE ]"
}
# Vars
SCTL_ACTIVE="systemctl --user is-active"
SCTL_FAILED="systemctl --user is-failed"
SCTL_STATUS="systemctl --user status"
SCTL_START="systemctl --user start"
SCTL_STOP="systemctl --user stop"
SCTL_RESTART="systemctl --user restart"
SCTL_INFO="[${cyan} systemctl${default} ]"
HYPR_INFO="[ systemctl ]"
INFO_ARROW="${yellow} ${default}"
INFO_CLOSE="${red} ${default} "
INFO_CHECK="${green} ${default} "
NOTIFY="notify-send -u low -t 5000 -e -i dialog-information"
DESKTOP_SESSION=$(echo $DESKTOP_SESSION | tr '[:upper:]' '[:lower:]')

# Session check for xdg-desktop-portals and session.target
case $DESKTOP_SESSION in
	hyprland)
		SERVICE="session.target"
		SERVICE_UPDATE
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
			$($SCTL_STOP session-*.target) && $($SCTL_START session-hyprland.target)
			echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Restarting ...$INFO_CHECK"
		SERVICE="xdg-desktop-portal*"
		SERVICE_UPDATE
			pgrep -f "$SERVICE" &>/dev/null &&\
				pkill -f $SERVICE &&\
				echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
		SERVICE="xdg-desktop-portal-hyprland"
		SERVICE_UPDATE
		$($SCTL_START $SERVICE.service)
		#sleep 1
		$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK" &&\
			hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
		SERVICE="xdg-desktop-portal"
		SERVICE_UPDATE
		$($SCTL_START $SERVICE.service)
		#sleep 1
		$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK" &&\
			hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
		SERVICE="xdg-desktop-portal-gtk"
		SERVICE_UPDATE
		$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK" &&\
			hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
		;;
	sway)
		SERVICE="session.target"
		SERVICE_UPDATE
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
			$($SCTL_STOP session-*.target) && $($SCTL_START session-sway.target)
			echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Restarting ...$INFO_CHECK"
		SERVICE="xdg-desktop-portal*"
		SERVICE_UPDATE
			pgrep -f "$SERVICE" &>/dev/null &&\
				pkill -f $SERVICE &&\
				echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
		SERVICE="xdg-desktop-portal-wlr"
		SERVICE_UPDATE
		$($SCTL_START $SERVICE.service)
		#sleep 1
		$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK" &&\
			$NOTIFY "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)"
		SERVICE="xdg-desktop-portal"
		SERVICE_UPDATE
		$($SCTL_START $SERVICE.service)
		#sleep 1
		$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK" &&\
			$NOTIFY "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)"
		;;
	*)
		echo "Unknow session"
		exit 1
		;;
esac

## Notifications
# We want mako as a daemon, not sure why, but looks good
# Note: If you restart portals, them mako dies! (dont troubleshoot)
SERVICE="mako"
SERVICE_UPDATE
if command -v "$SERVICE" &>/dev/null; then
	if pgrep "$SERVICE" &>/dev/null; then
		declare -r _PROC="1"
		if [ "$_PROC" = 1 ]; then
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
			pkill $SERVICE
			$($SCTL_ACTIVE $SERVICE.service) &>/dev/null && $($SCTL_STOP $SERVICE.service)
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Starting ..."
			$($SCTL_START $SERVICE.service)
			echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK"
			hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
		fi
	else
		$($SCTL_ACTIVE $SERVICE.service) &>/dev/null && $($SCTL_FAILED $SERVICE.service) &&\
			$($SCTL_STOP $SERVICE.service) &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW ${magenta}NOTE${default}: Maybe you killed portals?! So..."
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Starting ..."
		$($SCTL_START $SERVICE.service)
		echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK"
		hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
	fi
fi
SERVICE="dunst"
SERVICE_UPDATE
if command -v "$SERVICE" &>/dev/null; then
	if pgrep "$SERVICE" &>/dev/null; then
		declare -r _PROC="1"
		if [ "$_PROC" = 1 ]; then
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
			pkill $SERVICE
			$($SCTL_ACTIVE $SERVICE.service) &>/dev/null && $($SCTL_STOP $SERVICE.service)
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Starting ..."
			$($SCTL_START $SERVICE.service)
			echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK"
			hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
		fi
	else
		$($SCTL_ACTIVE $SERVICE.service) &>/dev/null && $($SCTL_FAILED $SERVICE.service) &&\
			$($SCTL_STOP $SERVICE.service) &&\
			echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW ${magenta}NOTE${default}: Maybe you killed portals?! So..."
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Starting ..."
		$($SCTL_START $SERVICE.service)
		echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK"
		hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
	fi
fi

# Polkit check and restart
polkit_kde="/usr/lib/x86_64-linux-gnu/libexec/polkit-kde-authentication-agent-1"
polkit_gnome="/usr/lib/policykit-1-gnome/polkit-gnome-authentication-agent-1"
if [ -f "$polkit_kde" ]; then
	SERVICE="plasma-polkit-agent"
	SERVICE_UPDATE
	echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ... $INFO_CLOSE"
	pgrep polkit-kde-auth &>/dev/null && pkill polkit-kde-auth
	#sleep 1
	$($SCTL_START $SERVICE.service)
		if [ "$DESKTOP_SESSION" = hyprland ]; then
			$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
				echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK" &&\
				$($NOTIFY "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)")
				#hyprctl notify -0 10000 "rgb(6AA84F)" "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)" &>/dev/null
		elif [ "$DESKTOP_SESSION" = sway ]; then
			$SCTL_ACTIVE $SERVICE.service &>/dev/null &&\
				echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK"
				$($NOTIFY "$HYPR_INFO$HYPR_SERVICE -> $($SCTL_ACTIVE $SERVICE.service)")
		fi
fi
if [ -f "$polkit_gnome" ];then
	pkill -f polkit-gnome-au
	#"$polkit_gnome"
fi

# Audio restart for integration
# NOTE: Keep order in list for avoiding integration issue
audio=( "wireplumber" "pipewire-pulse" "pipewire-alsa" "pipewire" )
for service in "${audio[@]}"; do
	SERVICE="$service"
	SERVICE_UPDATE
	if pgrep "$SERVICE" &>/dev/null; then
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $SERVICE is restarting ..."
		$($SCTL_RESTART $SERVICE)
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $($SCTL_ACTIVE $SERVICE.service)$INFO_CHECK"
	else
		echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW $SERVICE not found! $INFO_CLOSE"
	fi
done


# We need the bar up and running
# But we need time for audio services to restart
SERVICE="waybar"
SERVICE_UPDATE
! command -v "$SERVICE" &>/dev/null && echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Not found!$INFO_CLOSE" && exit 1
echo -e "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Stopping ...$INFO_CLOSE"
pkill "$SERVICE" &>/dev/null && sleep 1
echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Starting ..."
[ "$DESKTOP_SESSION" = sway ] && waybar -c $HOME/.config/waybar/config-sway &>/dev/null &
[ "$DESKTOP_SESSION" = hyprland ] && waybar -c $HOME/.config/waybar/config-hypr &>/dev/null &
echo "$SCTL_INFO$SERVICE_INFO$INFO_ARROW Started ...$INFO_CHECK"

[ "$DESKTOP_SESSION" = "sway" ] && swaymsg reload
