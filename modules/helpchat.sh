# Help Chat (GUI) - keyword based + db lookup
help_chat_gui() {
    [ -f data/commands.db ] || { zenity --error --text="data/commands.db not found"; return; }

    q=$(zenity --entry --title="Ask for help" --text="Ask: (e.g. how do I list files?)")
    [ -z "$q" ] && return

    # quick keyword replies
    lowerq=$(echo "$q" | tr '[:upper:]' '[:lower:]')

    if echo "$lowerq" | grep -Eiq "list|files|ls"; then
        hint="Try: ls -la (lists files including hidden)."
    elif echo "$lowerq" | grep -Eiq "permission|chmod"; then
        hint="Try: chmod 755 <file> to give rwx to owner, rx to group/others."
    elif echo "$lowerq" | grep -Eiq "search|find|grep"; then
        hint="Use: grep 'pattern' file OR find . -name '*.txt'"
    else
        hint=""
    fi

    # search commands.db for matching words in command name or description
    matches=$(grep -iE "$(echo "$q" | sed 's/[^a-zA-Z0-9]/ /g' | awk '{for(i=1;i<=NF;i++){printf("%s|",$i)}}' | sed 's/|$//')" data/commands.db 2>/dev/null | head -n 10)

    if [ -n "$matches" ]; then
        out="Suggested commands from DB:\n\n"
        while IFS= read -r m; do
            cmd=$(echo "$m" | cut -d"|" -f1)
            desc=$(echo "$m" | cut -d"|" -f2)
            out+="$cmd — $desc\n"
        done <<< "$matches"
    else
        out="No direct DB matches found."
    fi

    # combine automatic hint + db results
    full="$hint\n\n$out"
    zenity --info --title="Help" --width=520 --height=300 --text="$full"
}

