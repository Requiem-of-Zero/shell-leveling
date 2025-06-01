#!/opt/homebrew/bin
set -e

TODO_DIR="~/Documents/bash-practice/todo-list-manager"
DATE="$3"
TASK="$2"
ACTION="$1"



if [[ ! -f "$TODO_DIR/todo.json" ]]; then
  echo "{}" > "$TODO_DIR/todo.json"
fi