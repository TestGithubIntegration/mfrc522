#!/bin/bash
#set -ev # fail fast and hard
set -v # fail fast and hard

echo "Test example: $PLATFORMIO_CI_SRC";

stringContain() { [ -z "${2##*$1*}" ]; }

buildMe(){
        board=$1;
        echo '***build***';
        echo "board: $board";
        echo '***********';
        
        TMP=$(mktemp);
        var=$(platformio ci -v --lib=. --board="$board" 2> "$TMP");
        err=$(cat "$TMP");
        rm "$TMP";

        ## build
        output_unfiltered=$var;
        output_errors=$err;
        # filter and correct output for reviewdog
        output_reviewdog=$output_errors;
        # correct path to example file to report
        output_reviewdog=$(echo "$output_reviewdog" | sed "s/\/tmp\/[a-zA-Z0-9_]*\/src\/[a-zA-Z0-9_]*\.ino/${PLATFORMIO_CI_SRC//\//\\/}/g");
        # correct path to library files to report
        output_reviewdog=$(echo "$output_reviewdog" | sed 's/lib\/[a-zA-Z0-9_]*\///g');
        echo "--<Result>--";
        echo '###############';
#        echo "$output_reviewdog" | reviewdog -name="build_$board" -efm="%f:%l:%c: %m" -diff="git diff" -reporter=github-pr-check;
        echo "$output_reviewdog" | reviewdog -name="build_$board" -efm="%f:%l:%c: %m" -reporter=github-pr-check;
        echo '###############';
        echo "$output_reviewdog";
        echo '###############';
        echo "$output_unfiltered";
        echo '###############';
        echo "$output_unfiltered" | grep -i -E "^(Device|Data|Program|text|[0-9])";
}


buildBoardParam() {
        if stringContain "$2" "$1";
                then echo "check board group $board";
                shift # $1
                shift # $2
                arr=( "$@" ) # grab remaining arguments
                for i in "${arr[@]}";
                        do
                                echo "Trigger build for board: $i"
                                buildMe "$i"
                        done
        else
                echo "skip board test of $board";
        fi        
}


board='arduino_avr';
boardparam=('uno' 'megaatmega1280');
buildBoardParam "$TESTBOARD" "$board" "${boardparam[@]}"

board='arduino_arm';
boardparam=('due' 'zero');
buildBoardParam "$TESTBOARD" "$board" "${boardparam[@]}"

board='teensy';
boardparam=('teensy20' 'teensy31'); 
buildBoardParam "$TESTBOARD" "$board" "${boardparam[@]}"

board='esp';
boardparam=('d1_mini');
buildBoardParam "$TESTBOARD" "$board" "${boardparam[@]}"
