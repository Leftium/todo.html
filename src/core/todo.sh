#! /bin/bash

# Wrap todo.js so it can be run from the CLI.
# Ideally a drop-in replacement for todo.sh.

# NOTE:  Todo.sh requires the .todo/config configuration file to run.
# Place the .todo/config file in your home directory or use the -d option for a custom location.

# Exit if node.js not found.
command -v node >/dev/null 2>&1 || {
    echo >&2 "Requires node.js. Aborting.";
    exit 1;
}

TODO_SH=$(basename "$0")
TODO_FULL_SH="$0"
VERSION="DEV"
export TODO_SH TODO_FULL_SH VERSION

node wrapper.js "$HOME" "$@"

# echo [$TODO_SH exited with: $?]
exit $?
