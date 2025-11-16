#!/bin/bash

practice_tasks_gui() {

    DB_FILE="data/practice_tasks.db"

    # Check DB exists
    if [ ! -f "$DB_FILE" ]; then
        zenity --error --text="❌ practice_tasks.db NOT FOUND!"
        return
    fi

    # SHUFFLE LINES RANDOMLY
    mapfile -t QUESTIONS < <(shuf "$DB_FILE")

    SCORE=0
    TOTAL=${#QUESTIONS[@]}

    for item in "${QUESTIONS[@]}"; do
        
        # Extract ANSWER = text after the LAST comma
        ANSWER=$(echo "$item" | awk -F',' '{gsub(/^ +| +$/, "", $NF); print $NF}')

        # Extract QUESTION = everything except last comma
        QUESTION=$(echo "$item" | awk -F',' '{
            for(i=1; i<NF; i++) printf "%s ", $i;
            print ""
        }' | sed 's/[[:space:]]*$//')

        # Ask user
        USER_ANSWER=$(zenity --entry \
            --title="🧠 Practice Question" \
            --text=" $QUESTION ❓ " \
            --width=400)

        # If user cancels
        if [ $? -ne 0 ]; then
            return
        fi

        # Compare answers (case-insensitive)
        if [[ "${USER_ANSWER,,}" == "${ANSWER,,}" ]]; then
            zenity --info --text="✅ <b>Correct!</b> 🎉"
            SCORE=$((SCORE + 1))
        else
            zenity --warning --text="❌ <b>Incorrect</b> 😞\n\nCorrect answer:\n<b>$ANSWER</b>"
        fi
    done

    # Final score
    zenity --info \
        --title="🏁 Practice Completed" \
        --text="You scored: <b>$SCORE / $TOTAL</b> 🎯"
}
