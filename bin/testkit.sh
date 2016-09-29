#!/bin/bash

dir=$(d=$(dirname "$0"); cd "$d" && pwd)
if [ -f "./cgi-bin/parser3" ]; then
    path="./cgi-bin/parser3"
elif [ -f "./cgi-bin/parser3.cgi" ]; then
    path="./cgi-bin/parser3.cgi"
elif hash parser3 2>/dev/null; then
    path="parser3"
elif hash parser3.cgi 2>/dev/null; then
    path="parser3.cgi"
else
    path="${dir}/../parser/parser3.cgi"
fi

CGI_PARSER_CONFIG="${dir}/../parser/auto.p" bash -c "${path} \"${dir}/testkit.p\" $*"
