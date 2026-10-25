#!/usr/bin/env zsh

set -euo pipefail

script_name=$0

show_help() {
    echo "Usage: ${script_name} [-p <port>] [-f <path>] | [-h]"
    echo "  -p, --port <port> TCP port to listen for. Defaults to 80"
    echo "  -f, --file <path> A path to the file which content will be send in the server response"
    echo "  -h, --help        Show this help menu"
}

local port file help

# Brace expansions are great for specifying short and long
# option names without duplicating any information.
zparseopts -D -F -K - \
    {p,-port}:=port \
    {f,-file}:=file \
    {h,-help}=help || show_help

if [[ -n $help ]]; then
    show_help
    exit 0
fi

port=${port[2]:-80}

# check that port is a number
if [[ $port != <-> ]]; then
    echo "Port must be an integer, but got ${port}"
    exit 1
fi
echo "Using port: ${port}"

file=${file[2]:-}

if [[ -n $file ]]; then
    if [[ ! -e $file ]]; then
        echo "${file} does not exist"
        exit 1
    fi

    if [[ -d $file ]]; then
        echo "${file} is a directory"
        exit 1
    fi
    echo "Serving file: ${file}"
fi

# {var:+str} returns str if var is non null
while true; do
    content_length=${file:+"Content-Length: $(wc -c <$file)\r\n"}
    echo "HTTP/1.1 200 OK\r\n${content_length}\r\n${file:+$(bat $file)}" | nc -l ${port}
done
