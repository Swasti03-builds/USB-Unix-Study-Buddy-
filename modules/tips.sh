show_tip_gui() {
    [ -f data/commands.db ] || { zenity --error --text="data/commands.db missing"; return; }

    line=$(shuf -n 1 data/commands.db)
    cmd=$(echo "$line" | cut -d"|" -f1)
    desc=$(echo "$line" | cut -d"|" -f2)

    zenity --info \
        --title="Tip of the Day" \
        --width=300 --height=200 \
        --text="Tip of the Day:\n\n$cmd — $desc"
}

