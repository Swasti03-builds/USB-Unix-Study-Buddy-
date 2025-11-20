#!/bin/bash
practice_tasks_gui() {

    DB_FILE="data/practice_tasks.db"

    if [ ! -f "$DB_FILE" ]; then
        zenity --error --text="❌ practice_tasks.db NOT FOUND!"
        return
    fi

    mapfile -t QUESTIONS < <(shuf "$DB_FILE")

    SCORE=0
    TOTAL=${#QUESTIONS[@]}

    for item in "${QUESTIONS[@]}"; do
        ANSWER=$(echo "$item" | awk -F',' '{gsub(/^ +| +$/, "", $NF); print $NF}')

        QUESTION=$(echo "$item" | awk -F',' '{
            for(i=1; i<NF; i++) printf "%s ", $i;
            print ""
        }' | sed 's/[[:space:]]*$//')

        USER_ANSWER=$(zenity --entry \
            --title="🧠 Practice Question" \
            --text=" $QUESTION ❓ " \
            --width=400)

        if [ $? -ne 0 ]; then
            return
        fi

        if [[ "${USER_ANSWER,,}" == "${ANSWER,,}" ]]; then
            zenity --info --text="✅ <b>Correct!</b> 🎉"
            SCORE=$((SCORE + 1))
        else
            zenity --warning --text="❌ <b>Incorrect</b> 😞\n\nCorrect answer:\n<b>$ANSWER</b>"
        fi
    done
    zenity --info \
        --title="🏁 Practice Completed" \
        --text="You scored: <b>$SCORE / $TOTAL</b> 🎯"
}
