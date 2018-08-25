#!/bin/bash
#set -ev # fail fast and hard
set -v # fail fast and hard

echo "Test example: $PLATFORMIO_CI_SRC";

board_compile_param=""; # global variable

stringContain() { [ -z "${2##*$1*}" ]; }
buildBoardParam() {
        if stringContain "$2" "$1";
                then echo "check board $board";
                board_compile_param="$board_compile_param $3";
        else
                echo "skip board test of $board";
        fi        
}

board="arduino_avr";
boardparam="--board=uno --board=megaatmega1280";
buildBoardParam "$TESTBOARD" "$board" "$boardparam"

board="arduino_arm";
boardparam="--board=due --board=zero";
buildBoardParam "$TESTBOARD" "$board" "$boardparam"

board="teensy";
boardparam="--board=teensy20 --board=teensy31"; 
buildBoardParam "$TESTBOARD" "$board" "$boardparam"

board="esp";
boardparam="--board=d1_mini";
buildBoardParam "$TESTBOARD" "$board" "$boardparam"


buildMe(){
        board=$1;
        echo '***build***';
        echo "board: $board";
        
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
        echo "$output_reviewdog" | reviewdog -name="build_$board" -efm="%f:%l:%c: %m" -diff="git diff master" -reporter=github-pr-check;
        echo '###############';
        echo "$output_reviewdog";
        echo '###############';
        echo "$output_unfiltered";
        echo '###############';
        echo "$output_unfiltered" | grep -i -E "^(Device|Data|Program|text|[0-9])";
}

buildMe 'uno';
