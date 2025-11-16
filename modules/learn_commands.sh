#!/usr/bin/env bash

# === Gemini API endpoint ===
GEMINI_ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

# === Ask Gemini ===
ask_gemini() {
    local prompt="$1"

    if [ -z "$GEMINI_API_KEY" ]; then
        echo "ERROR: GEMINI_API_KEY not set"
        return 1
    fi

    response=$(
        jq -n --arg txt "$prompt" '{
            contents: [
                { parts: [ { "text": $txt } ] }
            ]
        }' |
        curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "x-goog-api-key: '"$GEMINI_API_KEY"'" \
            "$GEMINI_ENDPOINT" \
            -d @-
    )

    echo "$response" | jq -r '.candidates[0].content.parts[0].text // "No response"'
}

# === Get help/man text ===
get_help_text() {
    local cmd="$1"

    if help_out=$("$cmd" --help 2>/dev/null); then
        echo "$help_out"
        return
    fi

    if help_out=$(man "$cmd" 2>/dev/null | col -b | head -n 60); then
        echo "$help_out"
        return
    fi

    echo ""
}

# === MAIN GUI WINDOW (This is what you wanted) ===
learn_commands_gui() {
    while true; do

        # STEP 1 → Ask for command in a GUI entry box
        cmd=$(zenity --entry \
            --title="Learn UNIX Commands (AI)" \
            --text="Enter a command (e.g., ls, cd, grep)\nPress Cancel to return back.")

        # Cancel = return to main menu
        [ -z "$cmd" ] && return

        # STEP 2 → Validate command
        if ! command -v "$cmd" >/dev/null 2>&1; then
            zenity --error --text="Command '$cmd' not found on this system."
            continue
        fi

        # STEP 3 → Get official help text
        help_text=$(get_help_text "$cmd")
        help_text_short=$(echo "$help_text" | head -c 3500)

        # STEP 4 → Build AI prompt
        prompt=$(cat <<EOF
You are a Unix tutor for beginners.

Explain the Unix command "$cmd" simply.

Use only:

Explanation:
<short explanation>

Examples:
1) example
   - meaning
2) example
   - meaning
3) example
   - meaning

Reference:
$help_text_short
EOF
        )

        # STEP 5 → Call Gemini
        ai_output=$(ask_gemini "$prompt")

        # STEP 6 → Show AI output inside a persistent Zenity window
        zenity --text-info \
            --title="AI Explanation for '$cmd'" \
            --width=700 --height=600 \
            --filename=<(echo "$ai_output")

        # window stays open because the while loop continues

    done
}

