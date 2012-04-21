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

read -r -d '' JS_WRAPPER <<'END_OF_JS'
    require('./getopt.js');
    require('./todo.js');

    fs = require('fs');


    // Strip the first two arguments, which are specific to node.js.
    argv = process.argv.slice(2);

    exit = function(code) {
        process.exit(code);
    }

    ui = {
        echo: function(text) {
            console.log(text);
        },

        ask: function (prompt) {
            process.stdout.write(prompt);

            process.stdin.resume();
            var fs = require('fs');
            var response = fs.readSync(process.stdin.fd, 1024, 0, 'utf8');
            process.stdin.pause();

            return response[0].trim();
        },
    }

    // Synchronous methods that match more closely with twFile
    filesystem = {
        load: function(filePath) {
            result = null;

            try {
                result = fs.readFileSync(filePath, 'UTF8');
            } catch(e) {
            }
            return result;
        },

        save: function(filePath, content) {
            try {
                fs.writeFileSync(filePath, content, 'UTF8');
            } catch(e) {
                return false;
            }
            return true;
        }
    }

    var todo = new Todo(process.env, filesystem, ui);
    var exitCode = todo(argv);
    process.exit(exitCode);
END_OF_JS

node -e "$JS_WRAPPER" PREVENT_NODE_FROM_EATING_OPTIONS $@

echo $TODO_SH exited with: $?
exit $?
