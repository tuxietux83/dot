#!/usr/bin/bash
set -e # Stop the script on all errors
if [ "$(id -u)" == 0 ] ; then
   echo "Please don't run this script as root"
   exit 1
fi

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
# End
USER=$(whoami)
NEWPATH="$HOME/.config/${USER}_config"
USER_BASHRC="$NEWPATH/${USER}_bashrc"
USER_ALIASES="$NEWPATH/${USER}_bash_aliases"
USER_COLORS="$NEWPATH/colors.sh"

# Check for directory
if [[ -d "$NEWPATH" ]]; then
   echo "$NEWPATH -> ${green}Already exists${default}!"
   exit 0
else
   mkdir -v -p "$NEWPATH"
   echo "$NEWPATH -> ${red}Created${default}!"
fi
# Check for files
FILES=("$USER_BASHRC" "$USER_ALIASES" "$USER_COLORS")
for FILE in "${FILES[@]}"; do
   if [[ -f "$FILE" ]]; then
      echo "$FILE -> ${green}Already exists${default}!"
      exit 0
   else
      touch "$FILE"
      echo "$FILE -> ${red}Created${default}!"
   fi
done
# Modify ~/.bashrc
# Delimiters
filename="$HOME/.bashrc"
start_delimiter="# Bash Install start"
end_delimiter="# Bash Install end"

# Check for delimiters
if grep -Fxq "$start_delimiter" "$filename" && grep -Fxq "$end_delimiter" "$filename"; then
    # Delimiters exist, replace content
    sed -i "/$start_delimiter/,/$end_delimiter/c\\
$start_delimiter\\
mod_bashrc=\"$USER_BASHRC\"\\
if [[ -f \"\$mod_bashrc\" ]]; then\\
  . \"\$mod_bashrc\"\\
else\\
  echo \"No custom bashrc to be loaded!\"\\
fi\\
$end_delimiter" "$filename"
else
    # Delimiters do not exist, add content
    echo -e "$start_delimiter\n\
mod_bashrc=\"$USER_BASHRC\"\n\
if [[ -f \"\$mod_bashrc\" ]]; then\n\
  . \"\$mod_bashrc\"\n\
else\n\
  echo \"No custom bashrc to be loaded!\"\n\
fi\n\
$end_delimiter\n" >> "$filename"
fi

# -------------------------------------------------
# Adding custom colors file
colors_list=(
'#!/bin/bash'
'## Define'
''
'# Set'
'SBOLD="\[\e[1m\]"'
'SDIM="\[\e[2m\]"'
'SUNDERLINED="\[\e[4m\]"'
'SBLINK="\[\e[5m\]"'
'SREVERSE="\[\e[7m\]"'
'RESET="\[\033[0m\]"'
''
'# Colors foreground'
'FBLACK="\[\e[30m\]"'
'FRED="\[\e[31m\]"'
'FGREEN="\[\e[32m\]"'
'FYELLOW="\[\e[33m\]"'
'FBLUE="\[\e[34m\]"'
'FMAGENTA="\[\e[35m\]"'
'FCYAN="\[\e[36m\]"'
'FLIGHT_GRAY="\[\e[37m\]"'
'FDEFAULT="\[\e[39m\]"'
'FDARK_GRAY="\[\e[90m\]"'
'FLIGHT_RED="\[\e[91m\]"'
'FLIGHT_GREEN="\[\e[92m\]"'
'FLIGHT_YELLOW="\[\e[93m\]"'
'FLIGHT_BLUE="\[\e[94m\]"'
'FLIGHT_MAGENTA="\[\e[95m\]"'
'FLIGHT_CYAN="\[\e[96m\]"'
'FWHITE="\[\e[97m\]"'
''
'# Colors background'
'BBLACK="\[\e[40m\]"'
'BRED="\[\e[41m\]"'
'BGREEN="\[\e[42m\]"'
'BYELLOW="\[\e[43m\]"'
'BBLUE="\[\e[44m\]"'
'BMAGENTA="\[\e[45m\]"'
'BCYAN="\[\e[46m\]"'
'BLIGHT_GRAY="\[\e[47m\]"'
'BDEFAULT="\[\e[49m\]"'
'BDARK_GRAY="\[\e[100m\]"'
)
for colors in "${colors_list[@]}"; do
    echo "$colors" >> "$USER_COLORS"
done

# -------------------------------------------------
# Adding custom bashrc to USER_BASHRC
bashrc_list=(
  '# Exporting some paths'
  'export PATH=/usr/sbin:$PATH'
  ''
  '# Check for alias file and load it'
  "if [[ -f ${USER_ALIASES} ]]; then"
  "    . ${USER_ALIASES}"
  'fi'
  ''
  '# Check colors file and load it'
  "if [[ -f ${USER_COLORS} ]]; then"
  "   . ${USER_COLORS}"
  'fi'
  ''
  '# Custom PS1 for shell'
  'PS1="$FCYAN[$FRED$SBOLD\u$RESET$FCYAN]$FDEFAULT$BOLD@$RESET$FCYAN[$FYELLOW$BOLD\h$RESET$FCYAN]\w:>$RESET"'
  ''
  '# Check for neofetch and run it'
  'if command -v neofetch &>/dev/null; then'
  '    neofetch'
  'else'
  '    echo "neofetch is not installed."'
  'fi'
  ''
)
for bashrc in "${bashrc_list[@]}"; do
    echo "$bashrc" >> "$USER_BASHRC"
done

# -------------------------------------------------
# Adding aliases in USER_ALIASES
alias_list=(
  '#!/usr/bin/bash'
  'EDITOR=nano'
  "alias ebash=\"\$EDITOR ${USER_BASHRC} && source ${USER_BASHRC} && clear && echo -e ${USER_BASHRC} saved and reloaded ...\""
  "alias ealiases=\"\$EDITOR ${USER_ALIASES} && source ${USER_ALIASES} && clear && echo -e ${USER_ALIASES} saved and reloaded ...\""
  ''
  '# APT aliases'
  'alias update="sudo apt update && sudo apt list --upgradable"'
  'alias upgrade="sudo apt update && clear && sudo apt list --upgradable -a && read -r -p \"Press ENTER to continue or Ctrl+C to abort\" && sudo apt -y upgrade"'
  'alias clean="sudo apt autoremove"'
  'alias as="sudo apt search"'
  ''
  '# Check for yt-dlp and run it'
  'if command -v yt-dlp &>/dev/null; then'
  '    ytdlppath=$HOME/Downloads/yt-dlp'
  '      if [[ ! -d "$ytdlppath" ]]; then'
  '        mkdir -p $ytdlppath'
  '      fi'
  '    alias yt="cd $ytdlppath && yt-dlp -f '\''bestvideo[height<=1440]+bestaudio/best'\'' -P $ytdlppath -q --progress -N 200"'
  'else'
  '    echo "yt-dlp is not installed."'
  'fi'
)
for alias in "${alias_list[@]}"; do
    echo "$alias" >> "$USER_ALIASES"
done

# -------------------------------------------------
# Reload bashrc with new modifications
source ~/.bashrc
