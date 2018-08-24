#!/bin/bash
set -ev # fail fast and hard

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

## build
output=$(platformio ci -v --lib=. $board_compile_param);
echo "--<Result>--";
echo "$output" | reviewdog -efm="%f:%l:%c: %m" -diff="git diff master" -reporter=github-pr-check;
echo "$output";
echo "$output" | grep -i -E "^(Device|Data|Program|text|[0-9])";
