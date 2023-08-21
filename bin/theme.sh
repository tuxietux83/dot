#!/usr/bin/bash
set -e
COLUMNS=3
directories=(
$(ls -d ~/.themes/*)
$(ls -d /usr/share/themes/*)
)
options=()
for dir in ${directories[@]}; do
    dir_name=$(basename $dir)
    options+=(${dir_name%/*})
done

echo "Choose theme:"
select option in "${options[@]}" "Exit"; do
    case $option in
        "Exit")
            echo "Exit."
            exit 0
            ;;
        *)
            echo "Theme: $option"
            break
            ;;
    esac
done

theme="$option"
gsettings set org.gnome.desktop.interface gtk-theme "$theme"
gsettings set org.gnome.desktop.wm.preferences theme "$theme"
echo "gtk-theme: $(gsettings get org.gnome.desktop.interface gtk-theme)"
echo "wm-preferences: $(gsettings get org.gnome.desktop.wm.preferences theme)"
# Adaugă aici comanda reală pe care dorești să o rulezi pentru opțiunea selectată
