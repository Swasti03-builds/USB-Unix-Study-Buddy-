# Direct Document Viewer (GUI)

notes_gui() {
    mkdir -p data/docs

    # Read all files inside data/docs into array
    mapfile -t docs < <(find data/docs -maxdepth 1 -type f -printf "%f\n")

    if [ ${#docs[@]} -eq 0 ]; then
        zenity --warning --title="No Files" --text="No study materials found in data/docs/"
        return
    fi

    # Build Zenity list arguments
    zenity_args=()
    for f in "${docs[@]}"; do
        zenity_args+=("$f")
    done

    # Zenity list box
    selected=$(zenity --list \
        --title="Study Materials (PDF / PPT / DOC / Images)" \
        --width=600 --height=500 \
        --column="Files" \
        "${zenity_args[@]}")

    # If cancelled
    [ -z "$selected" ] && return

    # Open selected file
    xdg-open "data/docs/$selected" >/dev/null 2>&1 &
}

