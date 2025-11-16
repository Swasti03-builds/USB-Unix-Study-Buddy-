# Command Reference (GUI)
command_reference_gui() {
    [ -f data/commands.db ] || { zenity --error --text="data/commands.db not found"; return; }

    cmd=$(zenity --entry --title="Command Reference" --text="Enter command name (e.g. ls):")
    # if Cancel or empty
    [ -z "$cmd" ] && return

    # exact-start match (case-insensitive)
    line=$(grep -i "^$cmd|" data/commands.db | head -n1)

    if [ -z "$line" ]; then
        zenity --error --title="Not found" --text="Command '$cmd' not found in database."
        return
    fi

    command=$(echo "$line" | cut -d"|" -f1)
    description=$(echo "$line" | cut -d"|" -f2)
    syntax=$(echo "$line" | cut -d"|" -f3)
    example=$(echo "$line" | cut -d"|" -f4)

    zenity --info \
        --title="Reference: $command" \
        --width=650 --height=450 \
        --text="Command: $command\n\nDescription:\n$description\n\nSyntax:\n$syntax\n\nExample:\n$example"
}

