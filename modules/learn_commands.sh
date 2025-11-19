#!/usr/bin/env bash

# === Colors (same as main_menu.sh) ===
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
RESET="\e[0m"

# === Gemini generativelanguage endpoint (the one that worked in curl) ===
GEMINI_ENDPOINT="https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent"

# === Call Gemini with a prompt and get plain text back ===
ask_gemini() {
    local prompt="$1"

    if [ -z "$GEMINI_API_KEY" ]; then
        echo -e "${RED}GEMINI_API_KEY is not set. Please export it first.${RESET}"
        return 1
    fi

    response=$(
        jq -n --arg txt "$prompt" '{
            contents: [
                {
                    parts: [
                        { "text": $txt }
                    ]
                }
            ]
        }' \
        | curl -s -X POST \
            -H "Content-Type: application/json" \
            -H "x-goog-api-key: $GEMINI_API_KEY" \
            "$GEMINI_ENDPOINT" \
            -d @-
    )

    # Handle API errors
    local err
    err=$(echo "$response" | jq -r '.error.message // empty')
    if [ -n "$err" ]; then
        echo -e "${RED}API error:${RESET} $err"
        return 1
    fi

    echo "$response" | jq -r '.candidates[0].content.parts[0].text // "No response from model."'
}


# === Get --help or man text for a command ===
get_help_text() {
    local cmd="$1"
    local help_text

    # Try: cmd --help
    if help_text=$("$cmd" --help 2>/dev/null); then
        echo "$help_text"
        return
    fi

    # Fallback: man page (first 60 lines)
    if help_text=$(man "$cmd" 2>/dev/null | col -b | head -n 60); then
        echo "$help_text"
        return
    fi

    echo ""
}

# === Zenity GUI: Learn Unix Commands (AI) ===
learn_commands_gui() {
    while true; do
        # Ask for command
        cmd=$(zenity --entry \
            --title="Learn Unix Commands (AI)" \
            --text="Type the Unix command you want to learn about (e.g., ls, cd, grep)\n\nType 'b' to go back to the main menu." )

        # If user pressed Cancel, go back
        if [ $? -ne 0 ]; then
            return
        fi

        # If they type b → back (same logic as your script)
        if [ "$cmd" = "b" ]; then
            return
        fi

        # Empty input
        if [ -z "$cmd" ]; then
            zenity --warning --text="Please enter a command."
            continue
        fi

        # Check if command exists (same check as before)
        if ! command -v "$cmd" >/dev/null 2>&1; then
            zenity --error --text="This command is not installed or not found in PATH."
            continue
        fi

        # Collect help text (same function, same truncation)
        help_text=$(get_help_text "$cmd")
        help_text_short=$(printf "%s" "$help_text" | head -c 4000)

        # Build the SAME prompt you had
        prompt=$(cat <<EOF
You are a Unix tutor for beginners.

Explain the Unix command "$cmd" in the following format ONLY:

Explanation:
<one or two very simple lines explaining what this command does>

Examples:
1) <command example 1>
   - <one line simple explanation of what this example does>
2) <command example 2>
   - <one line simple explanation>
3) <command example 3>
   - <one line simple explanation>
(You may add a 4th example only if it is very useful.)

Rules:
- Use very simple language, suitable for a 1st year CS/IT student.
- Focus on practical usage, not history or theory.
- Do NOT add extra sections, only 'Explanation' and 'Examples'.

Here is the official help/man text for reference (use it to be accurate, but keep your explanation simple):

$help_text_short
EOF
)

        # Call Gemini using EXACT same logic
        ai_output=$(ask_gemini "$prompt")

        # Show whatever came back (including "API error:" text) in Zenity
        zenity --text-info \
            --title="AI Explanation for '$cmd'" \
            --width=700 --height=600 \
            --filename=<(echo "$ai_output")
    done
}



