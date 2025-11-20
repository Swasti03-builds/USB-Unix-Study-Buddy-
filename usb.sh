#!/bin/bash

source modules/tips.sh
source modules/quiz.sh
source modules/practice.sh
source modules/notes.sh
source modules/progress.sh
source modules/learn_commands.sh

show_tip_gui

while true; do
    choice=$(zenity --list \
        --title="UNIX Study Buddy" \
        --width=650 --height=450 \
        --column="Menu" \
        "Learn UNIX Commands (AI)" \
        "Quiz Mode" \
        "Practice Tasks" \
        "Notes" \
        "Progress Tracker" \
        "Exit")

    case "$choice" in
    	"Learn UNIX Commands (AI)") learn_commands_gui ;;# 
        "Quiz Mode") start_quiz_gui ;;
        "Practice Tasks") practice_tasks_gui ;;
        "Notes") notes_gui ;;
        "Progress Tracker") progress_gui ;;
        "Exit") exit ;;
        *) exit ;;
    esac
done

