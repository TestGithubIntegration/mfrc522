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
# Reset
Color_Off='\033[0m'       # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White
        echo -e "${Red}$output_reviewdog";
        echo '###############';
        #echo "$output_unfiltered";
        echo '###############';
        echo -e "${Cyan}$output_unfiltered" | grep -i -E "^(Device|Data|Program|text|[0-9])";
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
