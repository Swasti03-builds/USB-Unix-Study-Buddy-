# Tip of the Day (GUI)
show_tip_gui() {
    # Ensure file exists
    [ -f data/commands.db ] || { zenity --error --text="data/commands.db missing"; return; }

    # pick a random command and its short description
    line=$(shuf -n 1 data/commands.db)
    cmd=$(echo "$line" | cut -d"|" -f1)
    desc=$(echo "$line" | cut -d"|" -f2)

    zenity --info \
        --title="Tip of the Day" \
        --width=300 --height=200 \
        --text="Tip of the Day:\n\n$cmd — $desc"
}

