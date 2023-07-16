#!/bin/bash
set -e
#--------- For build testing ----------
# rm -v -r "$folder_path"
# -------------------------------------

### BackUp script
folder_format=$(date +%Y%m%d-%H%M)
folder_path="$HOME/Documents/backup"
folder="$folder_path/$folder_format"
restore_folder="$HOME/Documents/restore"

# Check for backup dir
if [ ! -d "$folder_path" ]; then
   mkdir -v -p "$folder_path"
fi

# Check if rsync is installed
if !command -v rsync &>/dev/null; then
   sudo apt install -y rsync
fi

# Function for performing backup
perform_backup() {
    mkdir -v -p "$folder"

    # Files and directories to include in backup
    files=(
         .bashrc
         .bash_aliases
         .bash_colors
         bin
         .config/dunst
         .config/geany
         .config/htop
         .config/i3
         .config/mpv
         .config/polybar
         .config/rofi
    )

    # Start to backup
    for file in "${files[@]}"; do
        if [ -f "$HOME/$file" ]; then
            echo "$HOME/$file -> ok "
            rsync -avS "$HOME/$file" "$folder/"
        elif [ -d "$HOME/$file" ]; then
            echo "$HOME/$file/ -> ok "
            mkdir -v -p "$folder/$file"
            rsync -avS "$HOME/$file/" "$folder/$file"
        else
           echo "$HOME/$file -> nok  "
        fi
    done
}

# Function for performing restore
perform_restore() {
    # List available backup folders
    available_backups=("$folder_path"/*)
    if [ ${#available_backups[@]} -eq 0 ]; then
        echo "No backups available for restore."
        exit 1
    fi

    echo "Available backups for restore:"
    for ((i = 0; i < ${#available_backups[@]}; i++)); do
        echo "$(($i + 1)): ${available_backups[$i]##*/}"
    done

    read -p "Select the backup number to restore (1-${#available_backups[@]}): " restore_selection

    if ! [[ "$restore_selection" =~ ^[0-9]+$ ]] || [ "$restore_selection" -lt 1 ] || [ "$restore_selection" -gt ${#available_backups[@]} ]; then
        echo "Invalid selection. Please enter a valid number."
        exit 1
    fi

    selected_backup="${available_backups[$((restore_selection - 1))]}"
    echo "Selected backup: ${selected_backup##*/}"

    read -p "Do you want to restore this backup? (y/n): " confirm_restore
    if [ "$confirm_restore" = "y" ]; then
        # Perform restore
        #rsync -avS "$selected_backup/" "$HOME/"
        rsync -avS "$selected_backup/" "$restore_folder"
        echo "Backup restored successfully!"
    else
        echo "Restore operation aborted."
    fi
}

# Present options to the user
echo "Select an option:"
echo "1: Perform backup"
echo "2: Perform restore"
read -p "Enter your choice (1 or 2): " user_choice

if [ "$user_choice" = "1" ]; then
    echo "Performing backup..."
    perform_backup
elif [ "$user_choice" = "2" ]; then
    echo "Performing restore..."
    perform_restore
else
    echo "Invalid choice. Please enter 1 or 2."
fi


