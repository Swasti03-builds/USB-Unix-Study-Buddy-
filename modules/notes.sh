notes_gui() {
    mkdir -p data/docs
    mapfile -t docs < <(find data/docs -maxdepth 1 -type f -printf "%f\n")

    if [ ${#docs[@]} -eq 0 ]; then
        zenity --warning --title="No Files" --text="No study materials found in data/docs/"
        return
    fi
    zenity_args=()
    for f in "${docs[@]}"; do
        zenity_args+=("$f")
    done
    selected=$(zenity --list \
        --title="Study Materials (PDF / PPT / DOC / Images)" \
        --width=600 --height=500 \
        --column="Files" \
        "${zenity_args[@]}")

    [ -z "$selected" ] && return
    xdg-open "data/docs/$selected" >/dev/null 2>&1 &
}

