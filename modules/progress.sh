# Progress Tracker (GUI)
progress_gui() {
    mkdir -p data

    # ----------- QUIZ SCORE PROCESSING -----------
    if [ -f data/scores.txt ] && [ -s data/scores.txt ]; then
        
        quizzes=$(wc -l < data/scores.txt)

        # Extract all percentages and calculate average
        avg=$(awk -F'|' '{gsub("%","",$4); sum+=$4; count++}
            END { if(count>0) printf("%.2f", sum/count); else print "0" }' data/scores.txt)

        # Extract best score
        best=$(awk -F'|' '{gsub("%","",$4); print $4}' data/scores.txt | sort -nr | head -n1)

        # Extract last played quiz time (first field, before first |)
        last_played=$(awk -F'|' 'END {print $1}' data/scores.txt)

    else
        quizzes=0
        avg="0.00"
        best="N/A"
        last_played="N/A"
    fi


    # ----------- POPUP RESULT -----------
    zenity --info \
        --title="Progress Tracker" \
        --width=500 --height=350 \
        --text="📊 <b>Your Progress Summary</b>\n
<b>Quiz Stats</b>
Total Quizzes Taken: $quizzes
Average Score: $avg%
Best Score: $best%
Last Played: $last_played"
}

