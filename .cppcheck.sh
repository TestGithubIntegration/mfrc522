#!/bin/bash
#set -ev # fail fast and hard and debug output
set -v # debug output

${CACHED}/${NAMEVER}/cppcheck --version

cppcheck_source=$(${CACHED}/${NAMEVER}/cppcheck --language=c++ --std=c++11 --enable=warning,style,performance,portability --template='{file}:{line}:{column}: {severity}: {message} {callstack}' $(find src/ -regextype posix-extended -regex ".*\.(h|c|hpp|cpp)") 2>&1 1>/dev/null);
echo "$cppcheck_source";
echo "$cppcheck_source" | reviewdog -name="cppcheck_source" -efm="%f:%l:%c: %m" -reporter=github-pr-check;

${CACHED}/${NAMEVER}/cppcheck --language=c++ --std=c++11 --enable=warning,style,performance,portability --template='{file}:{line}:{column}: {severity}: {message} {callstack}' $(find src/ -regextype posix-extended -regex ".*\.(h|c|hpp|cpp)");

cppcheck_example=$(${CACHED}/${NAMEVER}/cppcheck --language=c++ --std=c++11 --enable=warning,style,performance,portability --template='{file}:{line}:{column}: {severity}: {message} {callstack}' $(find examples/ -regextype posix-extended -regex ".*\.(h|c|hpp|cpp|ino)") 2>&1 1>/dev/null);
echo "$cppcheck_example";
echo "$cppcheck_example" | reviewdog -name="cppcheck_examples" -efm="%f:%l:%c: %m" -reporter=github-pr-check;


find src/ -regextype posix-extended -regex ".*\.(h|c|hpp|cpp)";
