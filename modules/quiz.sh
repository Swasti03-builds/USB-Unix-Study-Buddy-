start_quiz_gui() {

    # Step 1: Ask quiz level
    level=$(zenity --list \
        --title="Choose Quiz Level" \
        --column="Levels" \
        "Easy" "Medium" "Hard" \
        --width=650 --height=450)

    [ -z "$level" ] && return

    case "$level" in
        "Easy")    db="data/quiz_easy.db" ;;
        "Medium")  db="data/quiz_medium.db" ;;
        "Hard")    db="data/quiz_hard.db" ;;
    esac

    score=0
    total=0

    # 🔀 Shuffle questions before starting
    mapfile -t QUESTIONS < <(shuf "$db")

    # Ask only first 5 questions (or total available)
    for line in "${QUESTIONS[@]:0:5}"; do
        
        IFS='|' read -r question o1 o2 o3 o4 correct <<< "$line"

        [ -z "$question" ] && continue
        total=$((total+1))

        # ----- 🔀 SHUFFLE OPTIONS -----
        opts=( "$o1" "$o2" "$o3" "$o4" )
        shuffled_opts=( $(printf "%s\n" "${opts[@]}" | shuf) )

        for i in {0..3}; do
            if [[ "${shuffled_opts[$i]}" == "${opts[$((correct-1))]}" ]]; then
                new_correct=$((i+1))
            fi
        done

        # GUI Question
        ans=$(zenity --list \
            --title="Question $total" \
            --width=650 --height=450 \
            --ok-label="Select" \
            --text="<big><b>$question</b></big>\n\nChoose the correct option:" \
            --column="Options" --column="" \
            "A) ${shuffled_opts[0]}" "" \
            "B) ${shuffled_opts[1]}" "" \
            "C) ${shuffled_opts[2]}" "" \
            "D) ${shuffled_opts[3]}" "" )

        [ -z "$ans" ] && break

        case "$ans" in
            "A) ${shuffled_opts[0]}") choice=1 ;;
            "B) ${shuffled_opts[1]}") choice=2 ;;
            "C) ${shuffled_opts[2]}") choice=3 ;;
            "D) ${shuffled_opts[3]}") choice=4 ;;
            *) choice=0 ;;
        esac

        # FEEDBACK
        if [ "$choice" -eq "$new_correct" ]; then
            score=$((score+1))
            zenity --info \
                --title="Correct! 🎉" \
                --text="🎯 <b>Correct answer!</b>\n\nGreat job! 😄"
        else
            wrong_set=( "❌" "😬" "😕" "👎" "😢" )
            wrong=$(printf "%s\n" "${wrong_set[@]}" | shuf -n1)

            correct_text="${opts[$((correct-1))]}"

            zenity --error \
                --title="Incorrect $wrong" \
                --text="The correct answer was:\n\n<b>$correct_text</b>\n\nTry the next one!"
        fi

    done


    # ---------- SAVE SCORE TO scores.txt ----------
    mkdir -p data
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    percentage=$((score * 100 / total))

    echo "$timestamp | Level: $level | Score: $score/$total | $percentage%" >> data/scores.txt


    # ---------- FINAL SCORE POPUP ----------
    zenity --info \
        --title="Quiz Finished 🏁" \
        --text="Level: <b>$level</b>\nScore: <b>$score / $total</b>\nPercentage: <b>$percentage%</b>\n\n(Saved to scores.txt)"
}

