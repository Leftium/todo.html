root = exports ? this
oneline_usage = env = filesystem = ui = {};

# from http://coffeescriptcookbook.com/chapters/arrays/removing-duplicate-elements-from-arrays
Array::unique = ->
  output = {}
  output[@[key]] = @[key] for key in [0...@length]
  (value for key, value of output)


version = ->
    ui.echo("""
        TODO.HTML Command Line Interface v#{env.VERSION}

        First release: ??/??/2012
        Developed by: John-Kim Murphy (http://Leftium.com)
        Code repository: https://github.com/leftium/todo.html

        Based on idea by: Gina Trapani (http://ginatrapani.org)
        License: GPL http://www.gnu.org/copyleft/gpl.html
        """)
    exit 1


root.init = (_env, _filesystem, _ui) ->
    env = _env
    filesystem = _filesystem
    ui = _ui
    oneline_usage = "#{env.TODO_SH} [-fhpantvV] [-d todo_config] action [task_number] [task_description]"


usage = ->
    ui.echo("""
        Usage: #{oneline_usage}
        Try '#{env.TODO_SH} -h' for more information.
        """)
    exit 1


shorthelp = ->
    ui.echo("""
        Usage: #{oneline_usage}

        Actions:
          add|a "THING I NEED TO DO +project @context"
          addm "THINGS I NEED TO DO
                MORE THINGS I NEED TO DO"
          addto DEST "TEXT TO ADD"
          append|app ITEM# "TEXT TO APPEND"
          archive
          command [ACTIONS]
          deduplicate
          del|rm ITEM# [TERM]
          depri|dp ITEM#[, ITEM#, ITEM#, ...]
          do ITEM#[, ITEM#, ITEM#, ...]
          help
          list|ls [TERM...]
          listall|lsa [TERM...]
          listaddons
          listcon|lsc
          listfile|lf [SRC [TERM...]]
          listpri|lsp [PRIORITIES] [TERM...]
          listproj|lsprj [TERM...]
          move|mv ITEM# DEST [SRC]
          prepend|prep ITEM# "TEXT TO PREPEND"
          pri|p ITEM# PRIORITY
          replace ITEM# "UPDATED TODO"
          report
          shorthelp

        See "help" for more details.
        """)
    exit 0


help = ->
    ui.echo("""
        Usage: #{oneline_usage}

        Options:
          -@
              Hide context names in list output.  Use twice to show context
              names (default).
          -+
              Hide project names in list output.  Use twice to show project
              names (default).
          -c
              Color mode
          -d CONFIG_FILE
              Use a configuration file other than the default ~/.todo/config
          -f
              Forces actions without confirmation or interactive input
          -h
              Display a short help message; same as action "shorthelp"
          -p
              Plain mode turns off colors
          -P
              Hide priority labels in list output.  Use twice to show
              priority labels (default).
          -a
              Don't auto-archive tasks automatically on completion
          -A
              Auto-archive tasks automatically on completion
          -n
              Don't preserve line numbers; automatically remove blank lines
              on task deletion
          -N
              Preserve line numbers
          -t
              Prepend the current date to a task automatically
              when it's added.
          -T
              Do not prepend the current date to a task automatically
              when it's added.
          -v
              Verbose mode turns on confirmation messages
          -vv
              Extra verbose mode prints some debugging information and
              additional help text
          -V
              Displays version, license and credits
          -x
              Disables TODOTXT_FINAL_FILTER
          """)

    if (env.TODOTXT_VERBOSE > 1)
        ui.echo("""
            Environment variables:
              TODOTXT_AUTO_ARCHIVE            is same as option -a (0)/-A (1)
              TODOTXT_CFG_FILE=CONFIG_FILE    is same as option -d CONFIG_FILE
              TODOTXT_FORCE=1                 is same as option -f
              TODOTXT_PRESERVE_LINE_NUMBERS   is same as option -n (0)/-N (1)
              TODOTXT_PLAIN                   is same as option -p (1)/-c (0)
              TODOTXT_DATE_ON_ADD             is same as option -t (1)/-T (0)
              TODOTXT_VERBOSE=1               is same as option -v
              TODOTXT_DISABLE_FILTER=1        is same as option -x
              TODOTXT_DEFAULT_ACTION=""       run this when called with no arguments
              TODOTXT_SORT_COMMAND="sort ..." customize list output
              TODOTXT_FINAL_FILTER="sed ..."  customize list after color, P@+ hiding
              TODOTXT_SOURCEVAR=$DONE_FILE   use another source for listcon, listproj
            """)

    ui.echo("""
          Built-in Actions:
            add "THING I NEED TO DO +project @context"
            a "THING I NEED TO DO +project @context"
              Adds THING I NEED TO DO to your todo.txt file on its own line.
              Project and context notation optional.
              Quotes optional.

            addm "FIRST THING I NEED TO DO +project1 @context
            SECOND THING I NEED TO DO +project2 @context"
              Adds FIRST THING I NEED TO DO to your todo.txt on its own line and
              Adds SECOND THING I NEED TO DO to you todo.txt on its own line.
              Project and context notation optional.

            addto DEST "TEXT TO ADD"
              Adds a line of text to any file located in the todo.txt directory.
              For example, addto inbox.txt "decide about vacation"

            append ITEM# "TEXT TO APPEND"
            app ITEM# "TEXT TO APPEND"
              Adds TEXT TO APPEND to the end of the task on line ITEM#.
              Quotes optional.

            archive
              Moves all done tasks from todo.txt to done.txt and removes blank lines.

            command [ACTIONS]
              Runs the remaining arguments using only todo.sh builtins.
              Will not call any .todo.actions.d scripts.

            deduplicate
              Removes duplicate lines from todo.txt.

            del ITEM# [TERM]
            rm ITEM# [TERM]
              Deletes the task on line ITEM# in todo.txt.
              If TERM specified, deletes only TERM from the task.

            depri ITEM#[, ITEM#, ITEM#, ...]
            dp ITEM#[, ITEM#, ITEM#, ...]
              Deprioritizes (removes the priority) from the task(s)
              on line ITEM# in todo.txt.

            do ITEM#[, ITEM#, ITEM#, ...]
              Marks task(s) on line ITEM# as done in todo.txt.

            help
              Display this help message.

            list [TERM...]
            ls [TERM...]
              Displays all tasks that contain TERM(s) sorted by priority with line
              numbers.  Each task must match all TERM(s) (logical AND); to display
              tasks that contain any TERM (logical OR), use
              "TERM1|TERM2|..." (with quotes), or TERM1\|TERM2 (unquoted).
              Hides all tasks that contain TERM(s) preceded by a
              minus sign (i.e. -TERM). If no TERM specified, lists entire todo.txt.

            listall [TERM...]
            lsa [TERM...]
              Displays all the lines in todo.txt AND done.txt that contain TERM(s)
              sorted by priority with line  numbers.  Hides all tasks that
              contain TERM(s) preceded by a minus sign (i.e. -TERM).  If no
              TERM specified, lists entire todo.txt AND done.txt
              concatenated and sorted.

            listaddons
              Lists all added and overridden actions in the actions directory.

            listcon
            lsc
              Lists all the task contexts that start with the @ sign in todo.txt.

            listfile [SRC [TERM...]]
            lf [SRC [TERM...]]
              Displays all the lines in SRC file located in the todo.txt directory,
              sorted by priority with line  numbers.  If TERM specified, lists
              all lines that contain TERM(s) in SRC file.  Hides all tasks that
              contain TERM(s) preceded by a minus sign (i.e. -TERM).
              Without any arguments, the names of all text files in the todo.txt
              directory are listed.

            listpri [PRIORITIES] [TERM...]
            lsp [PRIORITIES] [TERM...]
              Displays all tasks prioritized PRIORITIES.
              PRIORITIES can be a single one (A) or a range (A-C).
              If no PRIORITIES specified, lists all prioritized tasks.
              If TERM specified, lists only prioritized tasks that contain TERM(s).
              Hides all tasks that contain TERM(s) preceded by a minus sign
              (i.e. -TERM).

            listproj
            lsprj
              Lists all the projects (terms that start with a + sign) in
              todo.txt.

            move ITEM# DEST [SRC]
            mv ITEM# DEST [SRC]
              Moves a line from source text file (SRC) to destination text file (DEST).
              Both source and destination file must be located in the directory defined
              in the configuration directory.  When SRC is not defined
              it's by default todo.txt.

            prepend ITEM# "TEXT TO PREPEND"
            prep ITEM# "TEXT TO PREPEND"
              Adds TEXT TO PREPEND to the beginning of the task on line ITEM#.
              Quotes optional.

            pri ITEM# PRIORITY
            p ITEM# PRIORITY
              Adds PRIORITY to task on line ITEM#.  If the task is already
              prioritized, replaces current priority with new PRIORITY.
              PRIORITY must be a letter between A and Z.

            replace ITEM# "UPDATED TODO"
              Replaces task on line ITEM# with UPDATED TODO.

            report
              Adds the number of open tasks and done tasks to report.txt.

            shorthelp
              List the one-line usage of all built-in and add-on actions.
        """)
    exit 1


die = (msg) ->
    ui.echo(msg)
    exit 1


cleaninput = (input, forSed) ->
    # Parameters:    When $1 = "for sed", performs additional escaping for use
    #                in sed substitution with "|" separators.
    # Precondition:  $input contains text to be cleaned.
    # Postcondition: Modifies $input.

    # Replace CR and LF with space; tasks always comprise a single line.
    input = input.replace(/\r/, ' ')
    input = input.replace(/\n/, ' ')

    return input


getPrefix = (todo_file) ->
    # Parameters:    $1: todo file; empty means $TODO_FILE.
    # Returns:       Uppercase FILE prefix to be used in place of "TODO:" where
    #                a different todo file can be specified.

    todo_file = todo_file || env.TODO_FILE
    todo_file = todo_file.replace(/^.*\/|\.[^.]*$/g, '')
    return todo_file.toUpperCase()


getTodo = (item, todoFile) ->
    # Parameters:    $1: task number
    #                $2: Optional todo file
    # Precondition:  $errmsg contains usage message.
    # Postcondition: $todo contains task text.
    if (not item) then die(env.errmsg)
    if (item.match(/[^0-9]/)) then die(env.errmsg)

    todo = filesystem.load(todoFile ? env.TODO_FILE).split('\n')[parseInt(item) - 1]

    if (!todo) then die("#{getPrefix(todoFile)}: No task #{item}.")
    return todo

regexpEscape = (str) ->
    # based on http://simonwillison.net/2006/jan/20/escape/
    str.replace(/[-[\]{}()*+?.,\\^$|#\s]/g, "\\$&")


replaceOrPrepend = (action, argv) ->
    switch action
        when 'replace'
            backref = ''
            querytext = 'Replacement: '
        when 'prepend'
            backref = ' $&'
            querytext = 'Prepend: '

    argv.shift(); item = argv.shift()
    todo = getTodo(item)

    if (not argv[0] && env.TODOTXT_FORCE is 0)
        input = ui.ask(querytext)
    else
        input = argv[0..].join(' ')
    input = cleaninput(input)

    # Retrieve existing priority and prepended date
    matches = todo.match(/^(\(.\) ){0,1}([0-9]{2,4}-[0-9]{2}-[0-9]{2} ){0,1}.*/)
    priority = matches?[1] ? ''
    prepdate = matches?[2] ? ''

    if prepdate and action is 'replace' and input.match(/^[0-9]{2,4}-[0-9]{2}-[0-9]{2}/)
        # If the replaced text starts with a date, it will replace the existing
        # date, too.
        prepdate = ''

    # Temporarily remove any existing priority and prepended date, perform the
    # change (replace/prepend) and re-insert the existing priority and prepended
    # date again.

    todo = todo.replace(new RegExp("^#{regexpEscape(priority)}#{prepdate}"), '')
    newtodo = todo.replace(/.*/, "#{priority}#{prepdate}#{input}#{backref}")

    todofile = filesystem.load(env.TODO_FILE)?.split('\n')
    if (todofile?)
        todofile[parseInt(item) - 1] = newtodo
        filesystem.save(env.TODO_FILE, todofile.join('\n').replace(/\n$/, ''))

    if env.TODOTXT_VERBOSE > 0
        switch action
            when 'replace'
                ui.echo "#{item} #{todo}"
                ui.echo "TODO: Replaced task with:"
                ui.echo "#{item} #{newtodo}"
            when 'prepend'
                ui.echo "#{item} #{newtodo}"


# This method roughly emulates how Bash would process todo.cfg: ignore
# #comments and process export commands. I know it is not perfect, but
# it should work satisfactorily for "well-formed" config files.
processConfig = (todoFileContents) ->

    processTodoCfgLine = (line) ->
        # ignore #comments
        line = line.replace(/#.*/, '')

        # todo.txt-cli tests touch a file to confirm config file run
        touchFile = line.match(/touch\s+(.*)/)
        if (touchFile)
            filesystem.save(touchFile[1].trim(), '')

        exportArgs = line.match(/export\s+(.*)=(.*)/)
        if (exportArgs)
            name = exportArgs[1]
            value = exportArgs[2]

            # Emulate Bash `dirname "$0"`
            # Get the current path sans filename
            path = env.PWD
            path = path.match(/^(.*)[\\\/].*?$/)[1]

            value = value.replace(/`\s*dirname\s+['"]\$0['"]\s*`/, path)

            # Strip (single) quotes from beginning and end
            value = value.match(/^["']*(.*?)["']*$/)[1]

            # Substitute $environment_variables
            variables = value.match(/\$[a-zA-Z_][a-zA-Z0-9_]*/g)

            if (variables)
                for variable in variables
                    re = new RegExp('\\' + variable, 'g')
                    value = value.replace(re, env[variable.slice(1)] || '')
            env[name] = value

    processTodoCfgLine(line) for line in todoFileContents.split('\n')


root.run = (argv) ->
    # Preserving environment variables so they don't get clobbered by the config file
    env.OVR_TODOTXT_AUTO_ARCHIVE = env.TODOTXT_AUTO_ARCHIVE
    env.OVR_TODOTXT_FORCE = env.TODOTXT_FORCE
    env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = env.TODOTXT_PRESERVE_LINE_NUMBERS
    env.OVR_TODOTXT_PLAIN = env.TODOTXT_PLAIN
    env.OVR_TODOTXT_DATE_ON_ADD = env.TODOTXT_DATE_ON_ADD
    env.OVR_TODOTXT_DISABLE_FILTER = env.TODOTXT_DISABLE_FILTER
    env.OVR_TODOTXT_VERBOSE = env.TODOTXT_VERBOSE
    env.OVR_TODOTXT_DEFAULT_ACTION = env.TODOTXT_DEFAULT_ACTION
    env.OVR_TODOTXT_SORT_COMMAND = env.TODOTXT_SORT_COMMAND
    env.OVR_TODOTXT_FINAL_FILTER = env.TODOTXT_FINAL_FILTER

    # == PROCESS OPTIONS ==
    while ((option = getopt(argv, ':fhpcnNaAtTvVx+@Pd:')) isnt '')
        switch (option)
            when '@'
                ## HIDE_CONTEXT_NAMES starts at zero (false); increment it to one
                ##   (true) the first time this flag is seen. Each time the flag
                ##   is seen after that, increment it again so that an even
                ##   number shows context names and an odd number hides context
                ##   names.
                env.HIDE_CONTEXT_NAMES = env.HIDE_CONTEXT_NAMES ? 0
                env.HIDE_CONTEXT_NAMES++
                if ((env.HIDE_CONTEXT_NAMES % 2) is 0)
                    ## Zero or even value -- show context names
                    env.HIDE_CONTEXTS_SUBSTITUTION = /^/;
                else
                    ## One or odd value -- hide context names
                    env.HIDE_CONTEXTS_SUBSTITUTION = /\s@[\x21-\x7E]{1,}/g

            when '+'
                ## HIDE_PROJECT_NAMES starts at zero (false); increment it to one
                ##   (true) the first time this flag is seen. Each time the flag
                ##   is seen after that, increment it again so that an even
                ##   number shows project names and an odd number hides project
                ##   names.
                env.HIDE_PROJECT_NAMES = env.HIDE_PROJECT_NAMES ? 0
                env.HIDE_PROJECT_NAMES++
                if ((env.HIDE_PROJECT_NAMES % 2) is 0)
                    ## Zero or even value -- show project names
                    env.HIDE_PROJECTS_SUBSTITUTION = /^/
                else
                    ## One or odd value -- hide project names
                    env.HIDE_PROJECTS_SUBSTITUTION = /\s[+][\x21-\x7E]{1,}/g

            when 'a'
                env.OVR_TODOTXT_AUTO_ARCHIVE = 0
            when 'A'
                env.OVR_TODOTXT_AUTO_ARCHIVE = 1
            when 'c'
                env.OVR_TODOTXT_PLAIN = 0
            when 'd'
                env.TODOTXT_CFG_FILE = optarg
            when 'f'
                env.OVR_TODOTXT_FORCE = 1
            when 'h'
                # Short-circuit option parsing and forward to the action.
                # Cannot just invoke shorthelp() because we need the configuration
                # processed to locate the add-on actions directory.
                argv = ['--', 'shorthelp']
                optreset = true
            when 'n'
                env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = 0
            when 'N'
                env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = 1
            when 'p'
                env.OVR_TODOTXT_PLAIN = 1
            when 'P'
                ## HIDE_PRIORITY_LABELS starts at zero (false); increment it to one
                ##   (true) the first time this flag is seen. Each time the flag
                ##   is seen after that, increment it again so that an even
                ##   number shows priority labels and an odd number hides priority
                ##   labels.
                env.HIDE_PRIORITY_LABELS = env.HIDE_PRIORITY_LABELS ? 0
                env.HIDE_PRIORITY_LABELS++
                if ((env.HIDE_PRIORITY_LABELS % 2) is 0)
                    ## Zero or even value -- show priority labels
                    env.HIDE_PRIORITY_SUBSTITUTION = /^\(\)/
                else
                    ## One or odd value -- hide priority labels
                    env.HIDE_PRIORITY_SUBSTITUTION = /([0-9]+ )\([A-Z]\)\s/
            when 't'
                env.OVR_TODOTXT_DATE_ON_ADD = 1
            when 'T'
                env.OVR_TODOTXT_DATE_ON_ADD = 0
            when 'v'
                env.TODOTXT_VERBOSE ?= 0
                env.TODOTXT_VERBOSE++
            when 'V'
                version()
            when 'x'
                env.OVR_TODOTXT_DISABLE_FILTER = 1

            when ':'
                ui.echo("Error - Option needs a value: #{optopt}")
                return 1
            when '?'
                ui.echo("Error - No such option: #{optopt}")
                return 1
            else
                ui.echo("Error - Option implemented yet: #{optopt}")
                return 1

    # defaults if not yet defined
    env.TODOTXT_VERBOSE ?= 1
    env.TODOTXT_PLAIN ?=  0
    env.TODOTXT_CFG_FILE ?= env.HOME + '/.todo/config'
    env.TODOTXT_FORCE ?= 0
    env.TODOTXT_PRESERVE_LINE_NUMBERS ?= 1
    env.TODOTXT_AUTO_ARCHIVE ?= 1
    env.TODOTXT_DATE_ON_ADD ?= 0
    env.TODOTXT_DEFAULT_ACTION ?= ''
    env.TODOTXT_SORT_COMMAND ?= ''
    env.TODOTXT_DISABLE_FILTER ?= ''
    env.TODOTXT_FINAL_FILTER ?= 'cat'

    # Default color map
    env.NONE         = ''
    env.BLACK        = '\\033[0;30m'
    env.RED          = '\\033[0;31m'
    env.GREEN        = '\\033[0;32m'
    env.BROWN        = '\\033[0;33m'
    env.BLUE         = '\\033[0;34m'
    env.PURPLE       = '\\033[0;35m'
    env.CYAN         = '\\033[0;36m'
    env.LIGHT_GREY   = '\\033[0;37m'
    env.DARK_GREY    = '\\033[1;30m'
    env.LIGHT_RED    = '\\033[1;31m'
    env.LIGHT_GREEN  = '\\033[1;32m'
    env.YELLOW       = '\\033[1;33m'
    env.LIGHT_BLUE   = '\\033[1;34m'
    env.LIGHT_PURPLE = '\\033[1;35m'
    env.LIGHT_CYAN   = '\\033[1;36m'
    env.WHITE        = '\\033[1;37m'
    env.DEFAULT      = '\\033[0m'

    # Default priority->color map.
    env.PRI_A = env.YELLOW        # color for A priority
    env.PRI_B = env.GREEN         # color for B priority
    env.PRI_C = env.LIGHT_BLUE    # color for C priority
    env.PRI_X = env.WHITE         # color unless explicitly defined

    # Default highlight colors.
    env.COLOR_DONE = env.LIGHT_GREY   # color for done (but not yet archived) tasks

    # Default sentence delimiters for todo.sh append.
    # If the text to be appended to the task begins with one of these characters, no
    # whitespace is inserted in between. This makes appending to an enumeration
    # (todo.sh add 42 ", foo") syntactically correct.
    env.SENTENCE_DELIMITERS = ',.:;'

    config = filesystem.load(env.TODOTXT_CFG_FILE)
    config ?= filesystem.load(env.HOME + '/todo.cfg')
    config ?= filesystem.load(env.HOME + '/.todo.cfg')
    config ?= filesystem.load(env.PWD + '/todo.cfg')

    # === SANITY CHECKS (thanks Karl!) ===

    if (not config) then die("Fatal Error: Cannot read configuration file #{env.TODOTXT_CFG_FILE}")
    processConfig(config)

    # === APPLY OVERRIDES
    if (env.OVR_TODOTXT_AUTO_ARCHIVE)
        env.TODOTXT_AUTO_ARCHIVE = env.OVR_TODOTXT_AUTO_ARCHIVE
    if (env.OVR_TODOTXT_FORCE)
        env.TODOTXT_FORCE = env.OVR_TODOTXT_FORCE
    if (env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS)
        env.TODOTXT_PRESERVE_LINE_NUMBERS = env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS
    if (env.OVR_TODOTXT_PLAIN)
        env.TODOTXT_PLAIN = env.OVR_TODOTXT_PLAIN
    if (env.OVR_TODOTXT_DATE_ON_ADD != undefined)
        env.TODOTXT_DATE_ON_ADD = env.OVR_TODOTXT_DATE_ON_ADD
    if (env.OVR_TODOTXT_DISABLE_FILTER)
        env.TODOTXT_DISABLE_FILTER = env.OVR_TODOTXT_DISABLE_FILTER
    if (env.OVR_TODOTXT_VERBOSE != undefined)
        env.TODOTXT_VERBOSE = env.OVR_TODOTXT_VERBOSE
    if (env.OVR_TODOTXT_DEFAULT_ACTION)
        env.TODOTXT_DEFAULT_ACTION = env.OVR_TODOTXT_DEFAULT_ACTION
    if (env.OVR_TODOTXT_SORT_COMMAND)
        env.TODOTXT_SORT_COMMAND = env.OVR_TODOTXT_SORT_COMMAND
    if (env.OVR_TODOTXT_FINAL_FILTER)
        env.TODOTXT_FINAL_FILTER = env.OVR_TODOTXT_FINAL_FILTER

    argv.shift() for [0...optind]
    action = argv[0] ? env.TODOTXT_DEFAULT_ACTION

    if (not action) then usage()

    # Create files if they don't exist yet.
    if (not filesystem.load(env.TODO_FILE)?)
        filesystem.save(env.TODO_FILE, '')
    if (not filesystem.load(env.DONE_FILE)?)
        filesystem.save(env.DONE_FILE, '')
    if (not filesystem.load(env.REPORT_FILE)?)
        filesystem.save(env.REPORT_FILE, '')

    if (env.TODOTXT_PLAIN)
        for clr of env
            if (clr.match(/^PRI/)) then env[clr] = env.NONE
        env.PRI_X = env.NONE
        env.DEFAULT = env.NONE
        env.COLOR_DONE = env.NONE


    # from http://stackoverflow.com/a/1267338/117030
    zeroFill = (number, width) ->
        width -= number.toString().length
        if ( width > 0 )
            return `new Array( width + (/\./.test( number ) ? 2 : 1) ).join( '0' ) + number`
        return number

    formattedDate = ->
        date = new Date()
        if (env.TODO_TEST_TIME)
            date = new Date(env.TODO_TEST_TIME * 1000)

        result = "#{date.getFullYear()}-" +
                 "#{zeroFill(date.getMonth() + 1, 2)}-" +
                 "#{zeroFill(date.getDate(), 2)}"

    _addto = (file, input) ->
        input = cleaninput(input)
        if (env.TODOTXT_DATE_ON_ADD)
            today = formattedDate()
            input = input.replace(/^(\([A-Z]\) ){0,1}/i, "$1#{today} ")
        result = filesystem.append(file, input)

        if (env.TODOTXT_VERBOSE > 0)
            tasknum = result.split('\n').length - 1
            ui.echo(tasknum + ' ' + input)
            ui.echo(getPrefix(file) + ': ' + tasknum + ' added.')

    shellquote = (str) ->
        # based on http://simonwillison.net/2006/jan/20/escape/
        str.replace(/[-\{}()+?,\\^$|#\s]/g, "\\$&")


    filtercommand = (filter, post_filter, search_terms) ->
        filters = []

        for search_term in search_terms
            ## See if the first character of $search_term is a dash
            if (search_term[0] != '-')
                ## First character isn't a dash: hide lines that don't match
                ## this $search_term
                filters.push(new RegExp(shellquote(search_term), 'i'))
            else
                ## First character is a dash: hide lines that match this
                ## $search_term

                ## Remove the first character (-) before adding to our filter command
                filters.push(new RegExp("^(?!.*#{shellquote(search_term[1..])})", 'i'))

        if (post_filter)
            filters.push(post_filter)
        return filters


    _list = (file, searchTerms, post_filter_command) ->
        # console.log('_list()');
        # console.log(file);
        # console.log(searchTerms);

        ## If the file starts with a "/" use absolute path. Otherwise,
        ## try to find it in either $TODO_DIR or using a relative path
        if (file[0] is '/')
            ## Absolute path
            src = file
        else if (filesystem.load(env.TODO_DIR + '/' + file)?)
            ## Path relative to todo.sh directory
            src = env.TODO_DIR + '/' + file
        else if (filesystem.load(file)?)
            ## Path relative to current working directory
            src = file
        else if (filesystem.load(env.TODO_DIR + '/' + file + '.txt')?)
            ## Path relative to todo.sh directory, missing file extension
            src = env.TODO_DIR + '/' + file + '.txt'
        else
            die('TODO: File ' + file + ' does not exist.')

        ## Get our search arguments, if any
        # shift ## was file name, new $1 is first search term

        _format(filesystem.load(src), null, searchTerms, post_filter_command)

        if (env.TODOTXT_VERBOSE > 0)
            ui.echo('--')
            ui.echo(getPrefix(src) + ": #{env.numTasks} of #{env.totalTasks} tasks shown")
        return 0


    _getPadding = (file) ->
        ## We need one level of padding for each power of 10 $LINES uses.
        lines = String(file.split('\n').length - 1)
        return lines.length


    _format = (file, padding, terms, post_filter_command, silent, numTask) ->
        # Parameters:    $1: todo input file; when empty formats stdin
        #                $2: ITEM# number width; if empty auto-detects from $1 / $TODO_FILE.
        # Precondition:  None
        # Postcondition: $NUMTASKS and $TOTALTASKS contain statistics (unless $TODOTXT_VERBOSE=0).

        ## Figure out how much padding we need to use, unless this was passed to us.
        padding = padding ? _getPadding(file)
        # shift

        highlight = (colorVar) ->
            color = env[colorVar.toUpperCase()] ? env.PRI_X
            color = color.replace(/\\+033/i, `"\033"`)
            return color

        items = file.split('\n')
        nonemptyItems = []
        db('numtask', 'numtask:' + numTask)
        for item, i in items
            if (item.match(/[\x21-\x7E]/))
                num = i + 1
                if (numTask && numTask < num)
                    num = 0
                nonemptyItems.push(zeroFill(num, padding) + ' ' + items[i])
                db('test', i)

        filters = filtercommand('', post_filter_command, terms)

        filteredItems = []

        if (filters.length)
            for item in nonemptyItems
                eligible = true
                for filter in filters
                    if (not item.match(filter))
                        eligible = false
                        break
                if (eligible)
                    filteredItems.push(item)
        else
            filteredItems = nonemptyItems

        filteredItems = filteredItems.sort((a, b) ->
            k = padding + 1
            a = a[k..].toUpperCase()
            b = b[k..].toUpperCase()
            return if a < b then -1 else 1)

        for item, i in filteredItems
            if (item.match(/^[0-9]+ x/))     # TODO: FIX REGEX
                item = highlight('COLOR_DONE') + item + highlight('DEFAULT')
            match = item.match(/^[0-9]+ \(([A-Z])\)/i)
            if (match)
                item = highlight('PRI_' + match[1]) + item + highlight('DEFAULT')
            filteredItems[i] = item

        for item, i in filteredItems
            item = item.replace(new RegExp(env.HIDE_PROJECTS_SUBSTITUTION), '')
            item = item.replace(new RegExp(env.HIDE_CONTEXTS_SUBSTITUTION), '')
            item = item.replace(env.HIDE_PRIORITY_SUBSTITUTION, '$1')
            item = item.replace(new RegExp(env.HIDE_CUSTOM_SUBSTITUTION, 'g'), '')

            filteredItems[i] = item

        if (not silent)
            ui.echo(item) for item in filteredItems

        if (env.TODOTXT_VERBOSE > 0)
            env.numTasks = filteredItems.length
            env.totalTasks = nonemptyItems.length

        if (env.TODOTXT_VERBOSE > 1)
            ui.echo('TODO DEBUG: Filters used were:')
            ui.echo(filters)

        return filteredItems.length

    # == HANDLE ACTION ==
    action = action?.toLowerCase()

    if (action == 'command')
        ## Get rid of "command" from arguments list
        argv.shift()
        ## Reset action to new first argument
        action = argv[0]?.toLowerCase()

    switch (action)
        when 'add', 'a'
            if(!argv[1] && env.TODOTXT_FORCE == 0)
                input = ui.ask('Add: ')
            else
                if(!argv[1]) then die('usage: ' + env.TODO_SH + ' add "TODO ITEM"')
                input = argv[1..].join(' ')
            # console.log(env.TODO_FILE);
            _addto(env.TODO_FILE, input)

        when 'addto'
            if(not argv[1]) then die('usage: ' + env.TODO_SH + ' addto DEST "TODO ITEM"')
            dest = env.TODO_DIR + '/' +  argv[1]
            if(not argv[2]) then die('usage: ' + env.TODO_SH + ' addto DEST "TODO ITEM"')
            input = argv[2..].join(' ')

            if (filesystem.load(dest)?)
                _addto(dest, input)
            else
                die('TODO: Destination file ' + dest + ' does not exist.')

        when 'del', 'rm'
            # replace deleted line with a blank line when TODOTXT_PRESERVE_LINE_NUMBERS is 1
            env.errmsg = 'usage: ' + env.TODO_SH + ' del ITEM# [TERM]'
            item = argv[1]
            todo = getTodo(item)

            if (not argv[2])
                if (env.TODOTXT_FORCE is 0)
                    answer = ui.ask('Delete ' + todo + '? (y/n)')
                else
                    answer = 'y'
                if (answer is 'y')
                    newTodoFile = filesystem.load(env.TODO_FILE).split('\n')
                    if (env.TODOTXT_PRESERVE_LINE_NUMBERS is 0)
                        # delete line (changes line numbers)
                        newTodoFile.splice(parseInt(item) - 1, 1)
                    else
                        newTodoFile[parseInt(item) - 1] = ''
                    newTodoFile = newTodoFile.join('\n').replace(/\n$/, '')
                    filesystem.save(env.TODO_FILE, newTodoFile)
                    if (env.TODOTXT_VERBOSE > 0)
                        ui.echo(item + ' ' + todo);
                        ui.echo('TODO: ' + item + ' deleted.')
                else
                    ui.echo('TODO: No tasks were deleted.')

        when 'help'
            help()

        when 'shorthelp'
            shorthelp()

        when 'list', 'ls'
            argv.shift()  # Was ls; new $1 is first search term
            _list(env.TODO_FILE, argv)

        when 'listall', 'lsa'
            argv.shift()  # Was lsa; new $1 is first search term

            total = filesystem.load(env.TODO_FILE).split('\n').length - 1
            padding = String(total).length

            todoContents = filesystem.load(env.TODO_FILE)
            doneContents = filesystem.load(env.DONE_FILE)
            combined_files = todoContents + doneContents

            saved_todo_text_verbose = env.TODOTXT_VERBOSE
            env.TODOTXT_VERBOSE = 0
            tasknum = _format(todoContents, padding, argv, null, true)
            _format(combined_files, padding, argv, null, false, tasknum)
            if (saved_todo_text_verbose > 0)
                tdone = filesystem.load(env.DONE_FILE).split('\n').length - 1
                tasknum = _format(todoContents, padding, argv, null, true)
                donenum = _format(doneContents, padding, argv, null, true)
                ui.echo('--')
                ui.echo(getPrefix(env.TODO_FILE) + ': ' + tasknum + ' of ' + total + ' tasks shown')
                ui.echo(getPrefix(env.DONE_FILE) + ': ' + donenum + ' of ' + tdone + ' tasks shown')
                ui.echo('total ' + (tasknum + donenum) + ' of ' + (total + tdone) + ' tasks shown')

        when 'listfile', 'lf'
            argv.shift(); # Was listfile, next $1 is file name
            if (not argv[0]?)
                # nothing
            else
                file = argv.shift() # Was filename; next $1 is first search term
                _list(file, argv)

        when 'listcon', 'lsc'
            file = filesystem.load(env.TODO_FILE)

            if (filenames = env.TODOTXT_SOURCEVAR?.split(' '))
                file = ''
                for filename in filenames
                    filename = filename.replace(/[(")]/g, '')
                    if filename is '$DONE_FILE'
                        filename = env.DONE_FILE
                    if filename is '$TODO_FILE'
                        filename = env.TODO_FILE

                    file += filesystem.load(filename.trim()) ? ''

            contexts = file.match(/(^|\s)@[\x21-\x7E]+/g)

            if (contexts)
                contexts = (context.trim() for context in contexts)
                contexts.sort()

                contexts = contexts.unique()

                ui.echo context for context in contexts

        when 'listproj', 'lsprj'
            file = filesystem.load(env.TODO_FILE);

            projects = file.match(/(^|\s)\+[\x21-\x7E]+/g);

            if (projects)
                projects = (project.trim() for project in projects)
                projects.sort()

                projects = projects.unique()

                ui.echo project for project in projects

        when 'listpri', 'lsp'
            argv.shift() # was "listpri", new $1 is priority to list or first TERM

            pri = argv[0]?.toUpperCase().match(/^(([A-Z]\-[A-Z])|([A-Z]))$/)
            if (pri)
                pri = pri[0]
                argv.shift()
            else
               pri = 'A-Z'

            _list(env.TODO_FILE, argv, new RegExp('^ *[0-9]\+ \\([' + pri + ']\\) '))

        when 'prepend', 'prep'
            env.errmsg = "usage: #{env.TODO_SH} prepend ITEM# \"TEXT TO PREPEND\""
            replaceOrPrepend 'prepend', argv

        when 'pri', 'p'
            item = argv[1]
            newpri = argv[2]?.toUpperCase()

            env.errmsg = "usage: #{env.TODO_SH} pri ITEM# PRIORITY\n" +
                         "note: PRIORITY must be anywhere from A to Z."

            if argv.length isnt 3 then die env.errmsg
            if not newpri.match(/^[A-Z]/) then die env.errmsg

            todo = getTodo item

            oldpri = ''
            if todo.match(/^\([A-Z]\) /)
                oldpri = todo[1]

            if oldpri isnt newpri
                newtodo = todo.replace(/^\(.\) /, '').replace(/^/, "(#{newpri}) ")

                todofile = filesystem.load(env.TODO_FILE)?.split('\n')
                if (todofile?)
                    todofile[parseInt(item) - 1] = newtodo
                    filesystem.save(env.TODO_FILE, todofile.join('\n'))

            if env.TODOTXT_VERBOSE > 0
                newtodo ?= todo
                ui.echo "#{item} #{newtodo}"
                if oldpri isnt newpri
                    if oldpri
                        ui.echo "TODO: #{item} re-prioritized from (#{oldpri}) to (#{newpri})."
                    else
                        ui.echo "TODO: #{item} prioritized (#{newpri})."

                if oldpri is newpri
                    ui.echo "TODO: #{item} already prioritized (#{newpri})."

        when 'replace'
            env.errmsg = "usage: #{env.TODO_SH} replace ITEM# \"UPDATED ITEM\""
            replaceOrPrepend('replace', argv)

        else
            usage()

    return 0
