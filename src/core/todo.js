            Todo = function(env, filesystem, ui) {

var version = function() {
    ui.echo(
        'TODO.HTML Command Line Interface v' + env.VERSION + '\n' +
        '\n' +
        'First release: ??/??/2012\n' +
        'Developed by: John-Kim Murphy (http://Leftium.com)\n' +
        'Code repository: https://github.com/leftium/todo.html\n' +
        '\n' +
        'Based on idea by: Gina Trapani (http://ginatrapani.org)\n' +
        'License: GPL http://www.gnu.org/copyleft/gpl.html');
    exit(1);
}

var oneline_usage = env.TODO_SH + "[-fhpantvV] [-d todo_config] action [task_number] [task_description]\n";

var usage = function()
{
    ui.echo(
        'Usage: ' + oneline_usage +
        "Try '" + env.TODO_SH + " -h' for more information.");
    exit(1);

}

var shorthelp = function()
{
    ui.echo(
        '  Usage: ' + oneline_usage + '\n' +

        '  Actions:\n' +
        '    add|a "THING I NEED TO DO +project @context"\n' +
        '    addm "THINGS I NEED TO DO\n' +
        '          MORE THINGS I NEED TO DO"\n' +
        '    addto DEST "TEXT TO ADD"\n' +
        '    append|app ITEM# "TEXT TO APPEND"\n' +
        '    archive\n' +
        '    command [ACTIONS]\n' +
        '    deduplicate\n' +
        '    del|rm ITEM# [TERM]\n' +
        '    depri|dp ITEM#[, ITEM#, ITEM#, ...]\n' +
        '    do ITEM#[, ITEM#, ITEM#, ...]\n' +
        '    help\n' +
        '    list|ls [TERM...]\n' +
        '    listall|lsa [TERM...]\n' +
        '    listaddons\n' +
        '    listcon|lsc\n' +
        '    listfile|lf [SRC [TERM...]]\n' +
        '    listpri|lsp [PRIORITIES] [TERM...]\n' +
        '    listproj|lsprj [TERM...]\n' +
        '    move|mv ITEM# DEST [SRC]\n' +
        '    prepend|prep ITEM# "TEXT TO PREPEND"\n' +
        '    pri|p ITEM# PRIORITY\n' +
        '    replace ITEM# "UPDATED TODO"\n' +
        '    report\n' +
        '    shorthelp\n\n' +

        '  Actions can be added and overridden using scripts in the actions\n' +
        '  directory.');

    //# Only list the one-line usage from the add-on actions. This assumes that
    //# add-ons use the same usage indentation structure as todo.sh.

    ui.echo('\n' +
        'See "help" for more details.');
    exit(0);
}

var help = function()
{
    ui.echo(
        '  Usage: '+ oneline_usage + '\n' +

        '  Options:\n' +
        '    -@\n' +
        '        Hide context names in list output.  Use twice to show context\n' +
        '        names (default).\n' +
        '    -+\n' +
        '        Hide project names in list output.  Use twice to show project\n' +
        '        names (default).\n' +
        '    -c\n' +
        '        Color mode\n' +
        '    -d CONFIG_FILE\n' +
        '        Use a configuration file other than the default ~/.todo/config\n' +
        '    -f\n' +
        '        Forces actions without confirmation or interactive input\n' +
        '    -h\n' +
        '        Display a short help message; same as action "shorthelp"\n' +
        '    -p\n' +
        '        Plain mode turns off colors\n' +
        '    -P\n' +
        '        Hide priority labels in list output.  Use twice to show\n' +
        '        priority labels (default).\n' +
        '    -a\n' +
        '        Don\'t auto-archive tasks automatically on completion\n' +
        '    -A\n' +
        '        Auto-archive tasks automatically on completion\n' +
        '    -n\n' +
        '        Don\'t preserve line numbers; automatically remove blank lines\n' +
        '        on task deletion\n' +
        '    -N\n' +
        '        Preserve line numbers\n' +
        '    -t\n' +
        '        Prepend the current date to a task automatically\n' +
        '        when it\'s added.\n' +
        '    -T\n' +
        '        Do not prepend the current date to a task automatically\n' +
        '        when it\'s added.\n' +
        '    -v\n' +
        '        Verbose mode turns on confirmation messages\n' +
        '    -vv\n' +
        '        Extra verbose mode prints some debugging information and\n' +
        '        additional help text\n' +
        '    -V\n' +
        '        Displays version, license and credits\n' +
        '    -x\n' +
        '        Disables TODOTXT_FINAL_FILTER');

    if(env.TODOTXT_VERBOSE > 1) {
        ui.echo(
            '  Environment variables:\n' +
            '    TODOTXT_AUTO_ARCHIVE            is same as option -a (0)/-A (1)\n' +
            '    TODOTXT_CFG_FILE=CONFIG_FILE    is same as option -d CONFIG_FILE\n' +
            '    TODOTXT_FORCE=1                 is same as option -f\n' +
            '    TODOTXT_PRESERVE_LINE_NUMBERS   is same as option -n (0)/-N (1)\n' +
            '    TODOTXT_PLAIN                   is same as option -p (1)/-c (0)\n' +
            '    TODOTXT_DATE_ON_ADD             is same as option -t (1)/-T (0)\n' +
            '    TODOTXT_VERBOSE=1               is same as option -v\n' +
            '    TODOTXT_DISABLE_FILTER=1        is same as option -x\n' +
            '    TODOTXT_DEFAULT_ACTION=""       run this when called with no arguments\n' +
            '    TODOTXT_SORT_COMMAND="sort ..." customize list output\n' +
            '    TODOTXT_FINAL_FILTER="sed ..."  customize list after color, P@+ hiding\n' +
            '    TODOTXT_SOURCEVAR=\$DONE_FILE   use another source for listcon, listproj\n');
    }

    ui.echo(
        '  Built-in Actions:\n' +
        '    add "THING I NEED TO DO +project @context"\n' +
        '    a "THING I NEED TO DO +project @context"\n' +
        '      Adds THING I NEED TO DO to your todo.txt file on its own line.\n' +
        '      Project and context notation optional.\n' +
        '      Quotes optional.\n\n' +

        '    addm "FIRST THING I NEED TO DO +project1 @context\n' +
        '    SECOND THING I NEED TO DO +project2 @context"\n' +
        '      Adds FIRST THING I NEED TO DO to your todo.txt on its own line and\n' +
        '      Adds SECOND THING I NEED TO DO to you todo.txt on its own line.\n' +
        '      Project and context notation optional.\n\n' +

        '    addto DEST "TEXT TO ADD"\n' +
        '      Adds a line of text to any file located in the todo.txt directory.\n' +
        '      For example, addto inbox.txt "decide about vacation"\n\n' +

        '    append ITEM# "TEXT TO APPEND"\n' +
        '    app ITEM# "TEXT TO APPEND"\n' +
        '      Adds TEXT TO APPEND to the end of the task on line ITEM#.\n' +
        '      Quotes optional.\n\n' +

        '    archive\n' +
        '      Moves all done tasks from todo.txt to done.txt and removes blank lines.\n\n' +

        '    command [ACTIONS]\n' +
        '      Runs the remaining arguments using only todo.sh builtins.\n' +
        '      Will not call any .todo.actions.d scripts.\n\n' +

        '    deduplicate\n' +
        '      Removes duplicate lines from todo.txt.\n\n' +

        '    del ITEM# [TERM]\n' +
        '    rm ITEM# [TERM]\n' +
        '      Deletes the task on line ITEM# in todo.txt.\n' +
        '      If TERM specified, deletes only TERM from the task.\n\n' +

        '    depri ITEM#[, ITEM#, ITEM#, ...]\n' +
        '    dp ITEM#[, ITEM#, ITEM#, ...]\n' +
        '      Deprioritizes (removes the priority) from the task(s)\n' +
        '      on line ITEM# in todo.txt.\n\n' +

        '    do ITEM#[, ITEM#, ITEM#, ...]\n' +
        '      Marks task(s) on line ITEM# as done in todo.txt.\n\n' +

        '    help\n' +
        '      Display this help message.\n\n' +

        '    list [TERM...]\n' +
        '    ls [TERM...]\n' +
        '      Displays all tasks that contain TERM(s) sorted by priority with line\n' +
        '      numbers.  Each task must match all TERM(s) (logical AND); to display\n' +
        '      tasks that contain any TERM (logical OR), use\n' +
        '      "TERM1\|TERM2\|..." (with quotes), or TERM1\\\|TERM2 (unquoted).\n' +
        '      Hides all tasks that contain TERM(s) preceded by a\n' +
        '      minus sign (i.e. -TERM). If no TERM specified, lists entire todo.txt.\n\n' +

        '    listall [TERM...]\n' +
        '    lsa [TERM...]\n' +
        '      Displays all the lines in todo.txt AND done.txt that contain TERM(s)\n' +
        '      sorted by priority with line  numbers.  Hides all tasks that\n' +
        '      contain TERM(s) preceded by a minus sign (i.e. -TERM).  If no\n' +
        '      TERM specified, lists entire todo.txt AND done.txt\n' +
        '      concatenated and sorted.\n\n' +

        '    listaddons\n' +
        '      Lists all added and overridden actions in the actions directory.\n\n' +

        '    listcon\n' +
        '    lsc\n' +
        '      Lists all the task contexts that start with the @ sign in todo.txt.\n\n' +

        '    listfile [SRC [TERM...]]\n' +
        '    lf [SRC [TERM...]]\n' +
        '      Displays all the lines in SRC file located in the todo.txt directory,\n' +
        '      sorted by priority with line  numbers.  If TERM specified, lists\n' +
        '      all lines that contain TERM(s) in SRC file.  Hides all tasks that\n' +
        '      contain TERM(s) preceded by a minus sign (i.e. -TERM).  \n' +
        '      Without any arguments, the names of all text files in the todo.txt\n' +
        '      directory are listed.\n\n' +

        '    listpri [PRIORITIES] [TERM...]\n' +
        '    lsp [PRIORITIES] [TERM...]\n' +
        '      Displays all tasks prioritized PRIORITIES.\n' +
        '      PRIORITIES can be a single one (A) or a range (A-C).\n' +
        '      If no PRIORITIES specified, lists all prioritized tasks.\n' +
        '      If TERM specified, lists only prioritized tasks that contain TERM(s).\n' +
        '      Hides all tasks that contain TERM(s) preceded by a minus sign\n\n' +
        '      (i.e. -TERM).  \n' +

        '    listproj\n' +
        '    lsprj\n' +
        '      Lists all the projects (terms that start with a + sign) in\n' +
        '      todo.txt.\n\n' +

        '    move ITEM# DEST [SRC]\n' +
        '    mv ITEM# DEST [SRC]\n' +
        '      Moves a line from source text file (SRC) to destination text file (DEST).\n' +
        '      Both source and destination file must be located in the directory defined\n' +
        '      in the configuration directory.  When SRC is not defined\n' +
        '      it\'s by default todo.txt.\n\n' +

        '    prepend ITEM# "TEXT TO PREPEND"\n' +
        '    prep ITEM# "TEXT TO PREPEND"\n' +
        '      Adds TEXT TO PREPEND to the beginning of the task on line ITEM#.\n' +
        '      Quotes optional.\n\n' +

        '    pri ITEM# PRIORITY\n' +
        '    p ITEM# PRIORITY\n' +
        '      Adds PRIORITY to task on line ITEM#.  If the task is already\n' +
        '      prioritized, replaces current priority with new PRIORITY.\n' +
        '      PRIORITY must be a letter between A and Z.\n\n' +

        '    replace ITEM# "UPDATED TODO"\n' +
        '      Replaces task on line ITEM# with UPDATED TODO.\n\n' +

        '    report\n' +
        '      Adds the number of open tasks and done tasks to report.txt.\n\n' +

        '    shorthelp\n' +
        '      List the one-line usage of all built-in and add-on actions.');

        addonHelp();
    exit(1);
}

var addonHelp = function() {
    return 0;
}

var die = function(msg) {
    ui.echo(msg);
    exit(1);
}

var cleaninput = function(input, forSed)
{
    // Parameters:    When $1 = "for sed", performs additional escaping for use
    //                in sed substitution with "|" separators.
    // Precondition:  $input contains text to be cleaned.
    // Postcondition: Modifies $input.

    // Replace CR and LF with space; tasks always comprise a single line.
    input = input.replace(/\r/, ' ');
    input = input.replace(/\n/, ' ');

    if (forSed) {
        // This action uses sed with "|" as the substitution separator, and & as
        // the matched string; these must be escaped.
        // Backslashes must be escaped, too, and before the other stuff.
        input = input.replace(/\/\//, '\/\/\/\/');
        input = input.replace(/|/, '\\|/');
        input = input.replace(/&/, '\\&');
    }
    return input;
}

var getPrefix = function(todo_file)
{
    // Parameters:    $1: todo file; empty means $TODO_FILE.
    // Returns:       Uppercase FILE prefix to be used in place of "TODO:" where
    //                a different todo file can be specified.

    todo_file = todo_file || env.TODO_FILE;
    todo_file = todo_file.replace(/^.*\/|\.[^.]*$/g, '');
    return todo_file.toUpperCase();
}

// This method roughly emulates how Bash would process todo.cfg: ignore
// #comments and process export commands. I know it is not perfect, but
// it should work satisfactorily for "well-formed" config files.

var processConfig = function(todoFileContents) {

    function processTodoCfgLine(line) {
        // ignore #comments
        line = line.replace(/#.*/, '');

        var exportArgs = line.match(/export\s+(.*)=(.*)/);
        if (exportArgs) {
            var name = exportArgs[1];
            var value = exportArgs[2];

            // Emulate Bash `dirname "$0"`
            // Get the current path sans filename
            var path = env.PWD;
            path = path.match(/^(.*)[\\\/].*?$/)[1];

            value = value.replace(/`\s*dirname\s+['"]\$0['"]\s*`/, path);

            // Strip (single) quotes from beginning and end
            value = value.match(/^["']*(.*?)["']*$/)[1];


            // Substitute $environment_variables
            var variables = value.match(/\$[a-zA-Z_][a-zA-Z0-9_]*/g);

            if (variables) {
                for(var i = 0; i < variables.length; i++) {
                    var re = new RegExp('\\' + variables[i], 'g');
                    value = value.replace(re, env[variables[i].slice(1)] || 'WOW');
                }
            }
            env[name] = value;
            // console.log(name +' = ' + value);
        }
    }

    var lines = todoFileContents.split('\n');

    for(var i=0; i < lines.length; i++) {
        processTodoCfgLine(lines[i]);
    }
}

return function(argv) {
    // Preserving environment variables so they don't get clobbered by the config file
    env.OVR_TODOTXT_AUTO_ARCHIVE = env.TODOTXT_AUTO_ARCHIVE;
    env.OVR_TODOTXT_FORCE = env.TODOTXT_FORCE;
    env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = env.TODOTXT_PRESERVE_LINE_NUMBERS;
    env.OVR_TODOTXT_PLAIN = env.TODOTXT_PLAIN;
    env.OVR_TODOTXT_DATE_ON_ADD = env.TODOTXT_DATE_ON_ADD;
    env.OVR_TODOTXT_DISABLE_FILTER = env.TODOTXT_DISABLE_FILTER;
    env.OVR_TODOTXT_VERBOSE = env.TODOTXT_VERBOSE;
    env.OVR_TODOTXT_DEFAULT_ACTION = env.TODOTXT_DEFAULT_ACTION;
    env.OVR_TODOTXT_SORT_COMMAND = env.TODOTXT_SORT_COMMAND;
    env.OVR_TODOTXT_FINAL_FILTER = env.TODOTXT_FINAL_FILTER;

    // == PROCESS OPTIONS ==
    var option;
    while ((option = getopt(argv, ':fhpcnNaAtTvVx+@Pd:')) != '') {
        switch (option) {
            case '@':
                // HIDE_CONTEXT_NAMES starts at zero (false); increment it to one
                //   (true) the first time this flag is seen. Each time the flag
                //   is seen after that, increment it again so that an even
                //   number shows context names and an odd number hides context
                //   names.
                env.HIDE_CONTEXT_NAMES = env.HIDE_CONTEXT_NAMES || 0;
                env.HIDE_CONTEXT_NAMES++;
                if ((env.HIDE_CONTEXT_NAMES % 2) == 0) {
                    // Zero or even value -- show context names
                    env.HIDE_CONTEXTS_SUBSTITUTION = '';
                } else {
                    env.HIDE_CONTEXTS_SUBSTITUTION = '\\s@[\\x21-\\x7E]\{1,\}';
                }
                break;
            case '+':
                // HIDE_PROJECT_NAMES starts at zero (false); increment it to one
                //   (true) the first time this flag is seen. Each time the flag
                //   is seen after that, increment it again so that an even
                //   number shows project names and an odd number hides project
                //   names.
                env.HIDE_PROJECT_NAMES = env.HIDE_PROJECT_NAMES || 0;
                env.HIDE_PROJECT_NAMES++;
                if ((env.HIDE_PROJECT_NAMES % 2) == 0) {
                    // Zero or even value -- show context names
                    env.HIDE_PROJECTS_SUBSTITUTION = '';
                } else {
                    env.HIDE_PROJECTS_SUBSTITUTION = '\\s[+][\\x21-\\x7E]\{1,\}';
                }
                break;
            case 'a':
                env.OVR_TODOTXT_AUTO_ARCHIVE = 0;
                break;
            case 'A':
                env.OVR_TODOTXT_AUTO_ARCHIVE = 1;
                break;
            case 'c':
                env.OVR_TODOTXT_PLAIN = 0;
                break;
            case 'd':
                env.TODOTXT_CFG_FILE = optarg;
                break;
            case 'f':
                env.OVR_TODOTXT_FORCE = 1;
                break;
            case 'h':
                // Short-circuit option parsing and forward to the action.
                // Cannot just invoke shorthelp() because we need the configuration
                // processed to locate the add-on actions directory.
                argv = ['--', 'shorthelp'];
                optreset = true;
                break;
            case 'n':
                env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = 0;
                break;
            case 'N':
                env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = 1;
                break;
            case 'p':
                env.OVR_TODOTXT_PLAIN = 1;
                break;
            case 'P':
                // HIDE_PRIORITY_LABELS starts at zero (false); increment it to one
                //   (true) the first time this flag is seen. Each time the flag
                //   is seen after that, increment it again so that an even
                //   number shows priority labels and an odd number hides priority
                //   labels.
                env.HIDE_PRIORITY_LABELS = env.HIDE_PRIORITY_LABELS || 0;
                env.HIDE_PRIORITY_LABELS++;
                if ((env.HIDE_PRIORITY_LABELS % 2) == 0) {
                    // Zero or even value -- show context names
                    env.HIDE_PRIORITY_SUBSTITUTION = '';
                } else {
                    env.HIDE_PRIORITY_SUBSTITUTION = '([A-Z])\s';
                }
                break;
            case 't':
                env.OVR_TODOTXT_DATE_ON_ADD = 1;
                break;
            case 'T':
                env.OVR_TODOTXT_DATE_ON_ADD = 0;
                break;
            case 'v':
                env.OVR_TODOTXT_VERBOSE = env.OVR_TODOTXT_VERBOSE || 0;
                env.OVR_TODOTXT_VERBOSE++;
                break;
            case 'V':
                version();
                break;
            case 'x':
                env.OVR_TODOTXT_DISABLE_FILTER = 1;
                break;

            case ':':
                ui.echo('Error - Option needs a value: ' + optopt);
                return 1;
            case '?':
                ui.echo('Error - No such option: ' + optopt);
                return 1;
            default:
                ui.echo('Error - Option implemented yet: ' + optopt);
                return 1;
        }
    }

    // defaults if not yet defined
    env.TODOTXT_VERBOSE = env.TODOTXT_VERBOSE || 1;
    env.TODOTXT_PLAIN = env.TODOTXT_PLAIN || 0;
    env.TODOTXT_CFG_FILE = env.TODOTXT_CFG_FILE || env.HOME + '/.todo/config';
    env.TODOTXT_FORCE = env.TODOTXT_FORCE || 0;
    env.TODOTXT_PRESERVE_LINE_NUMBERS = env.TODOTXT_PRESERVE_LINE_NUMBERS || 1;
    env.TODOTXT_AUTO_ARCHIVE = env.TODOTXT_AUTO_ARCHIVE || 1;
    env.TODOTXT_DATE_ON_ADD = env.TODOTXT_DATE_ON_ADD || 0;
    env.TODOTXT_DEFAULT_ACTION = env.TODOTXT_DEFAULT_ACTION || '';
    env.TODOTXT_SORT_COMMAND = env.TODOTXT_SORT_COMMAND || '';
    env.TODOTXT_DISABLE_FILTER = env.TODOTXT_DISABLE_FILTER || '';
    env.TODOTXT_FINAL_FILTER = env.TODOTXT_FINAL_FILTER || 'cat';

    // Default color map
    env.NONE         = '';
    env.BLACK        = '\\033[0;30m';
    env.RED          = '\\033[0;31m';
    env.GREEN        = '\\033[0;32m';
    env.BROWN        = '\\033[0;33m';
    env.BLUE         = '\\033[0;34m';
    env.PURPLE       = '\\033[0;35m';
    env.CYAN         = '\\033[0;36m';
    env.LIGHT_GREY   = '\\033[0;37m';
    env.DARK_GREY    = '\\033[1;30m';
    env.LIGHT_RED    = '\\033[1;31m';
    env.LIGHT_GREEN  = '\\033[1;32m';
    env.YELLOW       = '\\033[1;33m';
    env.LIGHT_BLUE   = '\\033[1;34m';
    env.LIGHT_PURPLE = '\\033[1;35m';
    env.LIGHT_CYAN   = '\\033[1;36m';
    env.WHITE        = '\\033[1;37m';
    env.DEFAULT      = '\\033[0m';

    // Default priority->color map.
    env.PRI_A = env.YELLOW;        // color for A priority
    env.PRI_B = env.GREEN;         // color for B priority
    env.PRI_C = env.LIGHT_BLUE;    // color for C priority
    env.PRI_X = env.WHITE;         // color unless explicitly defined

    // Default highlight colors.
    env.COLOR_DONE = env.LIGHT_GREY;   // color for done (but not yet archived) tasks

    // Default sentence delimiters for todo.sh append.
    // If the text to be appended to the task begins with one of these characters, no
    // whitespace is inserted in between. This makes appending to an enumeration
    // (todo.sh add 42 ", foo") syntactically correct.
    env.SENTENCE_DELIMITERS = ',.:;';

    var config = filesystem.load(env.TODOTXT_CFG_FILE);
    if (!config) {
        config = filesystem.load(env.HOME + '/todo.cfg');
    }
    if (!config) {
        config = filesystem.load(env.HOME + '/.todo.cfg');
    }
    if (!config) {
        config = filesystem.load(env.PWD + '/todo.cfg');
    }

    // === SANITY CHECKS (thanks Karl!) ===
    if (!config) { die('Fatal Error: Cannot read configuration file ' + env.PWD + '/todo.cfg'); }

    processConfig(config);

    // === APPLY OVERRIDES
    if (env.OVR_TODOTXT_AUTO_ARCHIVE) {
        env.TODOTXT_AUTO_ARCHIVE = env.OVR_TODOTXT_AUTO_ARCHIVE;
    }
    if (env.OVR_TODOTXT_FORCE) {
        env.TODOTXT_FORCE = env.OVR_TODOTXT_FORCE;
    }
    if (env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS) {
        env.TODOTXT_PRESERVE_LINE_NUMBERS = env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS;
    }
    if (env.OVR_TODOTXT_PLAIN) {
        env.TODOTXT_PLAIN = env.OVR_TODOTXT_PLAIN;
    }
    if (env.OVR_TODOTXT_DATE_ON_ADD !== undefined) {
        env.TODOTXT_DATE_ON_ADD = env.OVR_TODOTXT_DATE_ON_ADD;
    }
    if (env.OVR_TODOTXT_DISABLE_FILTER) {
        env.TODOTXT_DISABLE_FILTER = env.OVR_TODOTXT_DISABLE_FILTER;
    }
    if (env.OVR_TODOTXT_VERBOSE) {
        env.TODOTXT_VERBOSE = env.OVR_TODOTXT_VERBOSE;
    }
    if (env.OVR_TODOTXT_DEFAULT_ACTION) {
        env.TODOTXT_DEFAULT_ACTION = env.OVR_TODOTXT_DEFAULT_ACTION;
    }
    if (env.OVR_TODOTXT_SORT_COMMAND) {
        env.TODOTXT_SORT_COMMAND = env.OVR_TODOTXT_SORT_COMMAND;
    }
    if (env.OVR_TODOTXT_FINAL_FILTER) {
        env.TODOTXT_FINAL_FILTER = env.OVR_TODOTXT_FINAL_FILTER;
    }

    for (var i = 0; i < optind; i++) {
        argv.shift();
    }
    var action = argv[0] || env.TODOTXT_DEFAULT_ACTION;

    // console.log('action: ' + action);

    if (!action) { usage() };

    if (env.TODOTXT_PLAIN) {
        for (clr in env) {
            if (clr.search(/^PRI/) == 0) {
                env[clr] = env.NONE;
            }
        }
        env.PRI_X = env.NONE;
        env.DEFAULT = env.NONE;
        env.COLOR_DONE = env.NONE;
    }

    var formattedDate = function() {
        var date = new Date();

        var result = date.getFullYear() + '-';
        if (date.getMonth() < 9) {
            result += '0';
        }
        result += date.getMonth() + 1 + '-';
        result += date.getDate() + ' ';
        return  result;
    }

    var _addto = function(file, input) {

        input = cleaninput(input);
        if(env.TODOTXT_DATE_ON_ADD) {
            var now = formattedDate();
            input = input.replace(/^(\([A-Z]\) ){0,1}/, '$1' + now);
        }
        var result = filesystem.append(file, input);
        // console.log('env.TODOTXT_VERBOSE: ' + env.TODOTXT_VERBOSE);
        if(env.TODOTXT_VERBOSE > 0) {
            var tasknum = result.split('\n').length - 1;
            ui.echo(tasknum + ' ' + input);
            ui.echo(getPrefix(file) + ': ' + tasknum + ' added.');
        }
    }

    // == HANDLE ACTION ==
    action = (action && action.toLowerCase());

    // If the first argument is "command", run the rest of the arguments
    // using todo.sh builtins.
    // Else, run a actions script with the name of the command if it exists
    // or fallback to using a builtin
    if (action == 'command') {
        // Get rid of "command" from arguments list
        argv.shift();
        // Reset action to new first argument
        action = argv[0];
        if (action) { action = action.toLowerCase(); }
    } else if(filesystem.load(env.TODO_ACTIONS_DIR + '/' + action)) {
        ui.echo('Sorry, custom actions not supported (yet).');
        return 1;
    }

    // Only run if action isn't found in .todo.actions.d
    switch (action) {
        case 'add': case 'a':
            if(!argv[1] && env.TODOTXT_FORCE == 0) {
                input = ui.ask('Add: ');
            } else {
                if(!argv[1]) { die('usage: ' + env.TODO_SH + ' add "TODO ITEM"'); }
                input = argv.splice(1).join(' ');
            }
            // console.log(env.TODO_FILE);
            _addto(env.TODO_FILE, input);
            break;
       case 'addto':
            if(!argv[1]) { die('usage: ' + env.TODO_SH + ' addto DEST "TODO ITEM"'); }
            var dest = env.TODO_DIR + '/' +  argv[1];
            if(!argv[2]) { die('usage: ' + env.TODO_SH + ' addto DEST "TODO ITEM"'); }
            var input = argv.splice(2).join(' ');

            var contents = filesystem.load(dest);
            if (typeof contents === 'string') {
                _addto(dest, input);
            } else {
                die('TODO: Destination file ' + dest + ' does not exist.');
            }
            break;

        case 'help':
            help();
            break;
        case 'shorthelp':
            shorthelp();
            break;
        default:
            usage();
    }

    return 0;
}

            }; // Todo = function()
