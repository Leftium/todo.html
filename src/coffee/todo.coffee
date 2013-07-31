define [], () ->
    root = exports ? this
    oneline_usage = env = filesystem = ui = echo = exit = db = read = {}

# Regular todo.txt items should not start with whitespace,
# much less a regular alternation of tabs and spaces.
    TODO_PLACEHOLDER = '\t \t \t \t TODO PLACEHOLDER'
    DUPE_PLACEHOLDER = '\t \t \t \t DUPE PLACEHOLDER'


# returns all lines that pass regexp's in filters[]
    applyFilters = (filters, lines) ->
        # returns true if all regexp filters test true for line
        passesAll = (filters, str) ->
            for filter in filters
                if filters.length > 0  and false
                    console.log '\n\npassesAll()'
                    console.log str, filter
                    console.log filter.test str
                if not filter.test str then return false
            return true
        if filters.length > 0  and false
            console.log 'lines:', lines
        return (line for line in lines when passesAll filters, line)


# from http://coffeescriptcookbook.com/chapters/arrays/removing-duplicate-elements-from-arrays
    Array::unique = ->
      output = {}
      output[@[key]] = @[key] for key in [0...@length]
      (value for key, value of output)


# expands a "$name" to the value set in the environment (env[name])
    expand = (str) ->
        return str?.replace /\$[a-zA-Z_][a-zA-Z0-9_]*/g, (s) -> env[s[1..]] ? ''


    formattedDate = (attachTime)->
        date = new Date()
        if env.TODO_TEST_TIME
            date = new Date(env.TODO_TEST_TIME * 1000)

        result = "#{date.getFullYear()              }-" +
                 "#{zeroFill(date.getMonth() + 1, 2)}-" +
                 "#{zeroFill(date.getDate(),      2)}"

        if attachTime?
            result += "T#{zeroFill(date.getHours(),   2)}" +
                      ":#{zeroFill(date.getMinutes(), 2)}" +
                      ":#{zeroFill(date.getSeconds(), 2)}"
        return result



    loadSourceVarOrTodoFile = () ->
        if env.TODOTXT_SOURCEVAR?
            filenames = env.TODOTXT_SOURCEVAR.replace /[(")]/g, ''
            filenames = filenames.split(' ') ? [filenames]
            filenames = (expand filename for filename in filenames)
        else
            filenames = [env.TODO_FILE]

        content = ''
        for filename in filenames
            content += (filesystem.load(filename).trim() ? '')
        return content


    regexpEscape = (str) ->
        # based on http://simonwillison.net/2006/jan/20/escape/
        str.replace /[-[\]{}()*+?.,\\^$|#\s]/g, '\\$&'


# from http://stackoverflow.com/a/1267338/117030
    zeroFill = (number, width) ->
        width -= number.toString().length
        if width > 0
            return `new Array( width + (/\./.test( number ) ? 2 : 1) ).join( '0' ) + number`
        return number

# Given a filename, returns an array of todo items.
# Padded with a dummy item to allow natural indexing of todo items.
# Returns null if the file cannot be loaded
    loadTodoFile = (filename = env.TODO_FILE) ->
        todos = filesystem.load filename
        if not todos? then return null

        todos = "#{TODO_PLACEHOLDER}\n#{todos}".split '\n'

        # Last todo item is empty and extraneous due to splitting on newlines.
        while todos[todos.length - 1] is ''
            todos.length--
        return todos


    saveTodoFile = (todoItems, filename = env.TODO_FILE) ->
        if not todoItems? then return false

        todoItems = (todoItems[1..].join '\n') + '\n'
        # todoItems = todoItems.replace /\n+$/, '\n'

        filesystem.save filename, todoItems


    appendTodoFile = (appendItems, filename) ->
        if not appendItems? then return
        if not todos = loadTodoFile filename then return
        todos = todos.concat appendItems
        return saveTodoFile todos, filename


# This method roughly emulates how Bash would process todo.cfg: ignore
# #comments and process export commands. I know it is not perfect, but
# it should work satisfactorily for "well-formed" config files.
    processConfig = (todoFileContents) ->
        for line in todoFileContents.split('\n')
            # ignore #comments
            # TODO: better comment parsing
            line = line.replace /^#.*/, ''

            # SHIM: test-lib.sh touch a file to confirm config file run
            if touchFile = line.match(/touch\s+(.*)/)?[1].trim()
                filesystem.save touchFile, ''

            if exportArgs = line.match /export\s+(.*)=(.*)/
                [name, value] = exportArgs[1..3]

                # Emulate Bash `dirname "$0"`
                # Get the current path sans filename
                path = env.PWD

                value = value.replace /`\s*dirname\s+['"]\$0['"]\s*`/, path

                # Strip single/double quotes from beginning and end
                value = value.match(/^["']*(.*?)["']*$/)[1]

                # Substitute $environment_variables
                value = expand value

                env[name] = value


    version = ->
        echo """
            TODO.HTML Command Line Interface v0.2.9.4alpha

            First release: 05/17/2012
            Developed by: John-Kim Murphy (http://Leftium.com)
            Code repository: https://github.com/leftium/todo.html

            Based on idea by: Gina Trapani (http://ginatrapani.org)
            License: GPL http://www.gnu.org/copyleft/gpl.html
            """
        exit 1


    root.init = (_env, _filesystem, _ui, _system) ->
        env = _env
        filesystem = _filesystem
        ui = _ui
        echo = ui.echo
        read = ui.ask
        db = _system.db
        exit = _system.exit
        oneline_usage = "#{env.TODO_SH} [-fhpantvV] [-d todo_config] action [task_number] [task_description]"


    usage = ->
        echo """
            Usage: #{oneline_usage}
            Try '#{env.TODO_SH} -h' for more information.
            """
        exit 1


    shorthelp = ->
        echo """
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
            """
        exit 0


    help = ->
        echo """
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


              """

        if (env.TODOTXT_VERBOSE > 1)
            echo """
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

                """

        echo """
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

            """

        exit 1


    die = (msg) ->
        echo msg
        exit 1


    cleaninput = (input) ->
        # additional escaping for use
        # in sed not needed
        # Parameters:    input contains text to be cleaned.
        # Postcondition: returns modified input.

        # Replace CR and LF with space; tasks always comprise a single line.
        input = input.replace /\r/g, ' '
        input = input.replace /\n/g, ' '

        return input


    getPrefix = (filename = env.TODO_FILE) ->
        # Parameters:    filename: todo filename; empty means $TODO_FILE.
        # Returns:       Uppercase FILE prefix to be used in place of "TODO:" where
        #                a different todo file can be specified.

        return filename?.replace(/^.*\/|\.[^.]*$/g, '')
                       ?.toUpperCase()


    getTodo = (item, todoFile = env.TODO_FILE) ->
        # Parameters:    item: task number
        #                todoFile: Optional todo file
        # Precondition:  env.errmsg contains usage message.
        # Postcondition: returns task text.
        if not item then die env.errmsg
        if /[^0-9]/.test item then die env.errmsg

        todo = loadTodoFile(todoFile)?[parseInt item]

        if not todo
            die "#{getPrefix(todoFile)}: No task #{item}."

        return todo

    getNewTodo = () ->
        # Just a placeholder


    replaceOrPrepend = (action, argv) ->
        switch action
            when 'replace'
                backref = ''
                querytext = "Replacement: "
            when 'prepend'
                backref = ' $&'
                querytext = "Prepend: "

        argv.shift(); item = argv.shift()
        todo = getTodo item

        if not argv[0] and env.TODOTXT_FORCE is 0
            input = read querytext
        else
            input = argv[0..].join(' ')
        input = cleaninput input

        # Retrieve existing priority and prepended date
        matches = todo.match /^(\(.\) ){0,1}([0-9]{2,4}-[0-9]{2}-[0-9]{2} ){0,1}.*/
        priority = matches?[1] ? ''
        prepdate = matches?[2] ? ''

        if prepdate and action is "replace" and /^[0-9]{2,4}-[0-9]{2}-[0-9]{2}/.test input
            # If the replaced text starts with a date, it will replace the existing
            # date, too.
            prepdate = ''

        # Temporarily remove any existing priority and prepended date, perform the
        # change (replace/prepend) and re-insert the existing priority and prepended
        # date again.

        newtodo = todo.replace(new RegExp("^#{regexpEscape(priority)}#{prepdate}"), '')
                      .replace(/.*/, "#{priority}#{prepdate}#{input}#{backref}")

        if todos = loadTodoFile()
            todos[parseInt item] = newtodo
            saveTodoFile todos

        if env.TODOTXT_VERBOSE > 0
            switch action
                when 'replace'
                    echo "#{item} #{todo}"
                    echo "TODO: Replaced task with:"
                    echo "#{item} #{newtodo}"
                when 'prepend'
                    echo "#{item} #{newtodo}"

    root.run = (argv) ->
        # Preserving environment variables so they don't get clobbered by the config file
        env.OVR_TODOTXT_AUTO_ARCHIVE = env.TODOTXT_AUTO_ARCHIVE
        env.OVR_TODOTXT_FORCE = env.TODOTXT_FORCE
        env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS = env.TODOTXT_PRESERVE_LINE_NUMBERS
        env.OVR_TODOTXT_PLAIN = env.TODOTXT_PLAIN
        env.OVR_TODOTXT_DATE_ON_ADD = env.TODOTXT_DATE_ON_ADD
        env.OVR_TODOTXT_VERBOSE = env.TODOTXT_VERBOSE
        env.OVR_TODOTXT_DEFAULT_ACTION = env.TODOTXT_DEFAULT_ACTION

        # == PROCESS OPTIONS ==
        resetopt()
        while (option = getopt(argv, ':fhpcnNaAtTvVx+@Pd:')) isnt ''
            switch option
                when '@'
                    ## HIDE_CONTEXT_NAMES starts at zero (false); increment it to one
                    ##   (true) the first time this flag is seen. Each time the flag
                    ##   is seen after that, increment it again so that an even
                    ##   number shows context names and an odd number hides context
                    ##   names.
                    env.HIDE_CONTEXT_NAMES ?= 0
                    env.HIDE_CONTEXT_NAMES++
                    if env.HIDE_CONTEXT_NAMES % 2 is 0
                        ## Zero or even value -- show context names
                        env.HIDE_CONTEXTS_SUBSTITUTION = /^/
                    else
                        ## One or odd value -- hide context names
                        env.HIDE_CONTEXTS_SUBSTITUTION = /\s@[\x21-\x7E]{1,}/g

                when '+'
                    ## HIDE_PROJECT_NAMES starts at zero (false); increment it to one
                    ##   (true) the first time this flag is seen. Each time the flag
                    ##   is seen after that, increment it again so that an even
                    ##   number shows project names and an odd number hides project
                    ##   names.
                    env.HIDE_PROJECT_NAMES ?= 0
                    env.HIDE_PROJECT_NAMES++
                    if env.HIDE_PROJECT_NAMES % 2 is 0
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
                    env.HIDE_PRIORITY_LABELS ?= 0
                    env.HIDE_PRIORITY_LABELS++
                    if env.HIDE_PRIORITY_LABELS % 2 is 0
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
                    # OVR_TODOTXT_DISABLE_FILTER not used.
                    false

                when ':'
                    echo "Error - Option needs a value: #{optopt}"
                    return 1
                when '?'
                    echo "Error - No such option: #{optopt}"
                    return 1
                else
                    echo "Error - Option not implemented yet: #{optopt}"
                    console.log option
                    return 1

        argv.shift() for [0...optind]

        # defaults if not yet defined
        env.TODOTXT_VERBOSE ?= 1
        env.TODOTXT_PLAIN ?= 0
        env.TODOTXT_CFG_FILE ?= env.HOME + '/.todo/config'
        env.TODOTXT_FORCE ?= 0
        env.TODOTXT_PRESERVE_LINE_NUMBERS ?= 1
        env.TODOTXT_AUTO_ARCHIVE ?= 1
        env.TODOTXT_DATE_ON_ADD ?= 0
        env.TODOTXT_DEFAULT_ACTION ?= ''

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

        config = filesystem.load env.TODOTXT_CFG_FILE
        config ?= filesystem.load "#{env.HOME}/todo.cfg"
        config ?= filesystem.load "#{env.HOME}/.todo.cfg"
        config ?= filesystem.load "#{env.PWD}/todo.cfg"

        # === SANITY CHECKS (thanks Karl!) ===

        if not config then die "Fatal Error: Cannot read configuration file #{env.TODOTXT_CFG_FILE}"
        processConfig config

        # === APPLY OVERRIDES
        if env.OVR_TODOTXT_AUTO_ARCHIVE?
            env.TODOTXT_AUTO_ARCHIVE = env.OVR_TODOTXT_AUTO_ARCHIVE
        if env.OVR_TODOTXT_FORCE?
            env.TODOTXT_FORCE = env.OVR_TODOTXT_FORCE
        if env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS?
            env.TODOTXT_PRESERVE_LINE_NUMBERS = env.OVR_TODOTXT_PRESERVE_LINE_NUMBERS
        if env.OVR_TODOTXT_PLAIN?
            env.TODOTXT_PLAIN = env.OVR_TODOTXT_PLAIN
        if env.OVR_TODOTXT_DATE_ON_ADD?
            env.TODOTXT_DATE_ON_ADD = env.OVR_TODOTXT_DATE_ON_ADD
        if env.OVR_TODOTXT_VERBOSE?
            env.TODOTXT_VERBOSE = env.OVR_TODOTXT_VERBOSE
        if env.OVR_TODOTXT_DEFAULT_ACTION?
            env.TODOTXT_DEFAULT_ACTION = env.OVR_TODOTXT_DEFAULT_ACTION
        action = argv[0] ? env.TODOTXT_DEFAULT_ACTION

        if not action then usage()

        # Create files if they don't exist yet.
        if not filesystem.load(env.TODO_FILE)? then filesystem.save env.TODO_FILE, ''
        if not filesystem.load(env.DONE_FILE)? then filesystem.save env.DONE_FILE, ''
        if not filesystem.load(env.REPORT_FILE)? then filesystem.save env.REPORT_FILE, ''

        if env.TODOTXT_PLAIN
            for clr of env when clr.match /^PRI_/
                env[clr] = env.NONE
            env.PRI_X = env.NONE
            env.DEFAULT = env.NONE
            env.COLOR_DONE = env.NONE


        _addto = (file, input) ->
            input = cleaninput input
            if env.TODOTXT_DATE_ON_ADD
                now = formattedDate()
                input = input.replace /^(\([A-Z]\) ){0,1}/i, "$1#{now} "
            todos = loadTodoFile file
            todos.push input

            saveTodoFile todos, file

            if env.TODOTXT_VERBOSE > 0
                tasknum = todos.length - 1
                echo "#{tasknum} #{input}"
                echo "#{getPrefix(file)}: #{tasknum} added."

        shellquote = (str) ->
            # based on http://simonwillison.net/2006/jan/20/escape/
            str.replace /[-\{}()+?,\\^$|#\s]/g, '\\$&'


        filtercommand = (pre_filter, post_filter, search_terms) ->
            filters = []

            for search_term in search_terms
                ## See if the first character of $search_term is a dash
                if search_term[0] != '-'
                    ## First character isn't a dash: hide lines that don't match
                    ## this $search_term
                    filters.push new RegExp(shellquote(search_term), 'i')
                else
                    ## First character is a dash: hide lines that match this
                    ## $search_term
                    #
                    ## Remove the first character (-) before adding to our filter command
                    filters.push new RegExp("^(?!.*#{shellquote(search_term[1..])})", 'i')

            if post_filter
                filters.push post_filter
            return filters


        _list = (file, searchTerms, postFilterRegexp) ->
            ## If the file starts with a "/" use absolute path. Otherwise,
            ## try to find it in either $TODO_DIR or using a relative path
            if file[0] is '/'
                ## Absolute path
                src = file
            else if filesystem.load("#{env.TODO_DIR}/#{file}")?
                ## Path relative to todo.sh directory
                src = "#{env.TODO_DIR}/#{file}"
            else if filesystem.load(file)?
                ## Path relative to current working directory
                src = file
            else if filesystem.load("#{env.TODO_DIR}/#{file}.txt")?
                ## Path relative to todo.sh directory, missing file extension
                src = "#{env.TODO_DIR}/#{file}.txt"
            else
                die "TODO: File #{file} does not exist."

            ## Get our search arguments, if any
            _format loadTodoFile(src), null, searchTerms, postFilterRegexp

            if env.TODOTXT_VERBOSE > 0
                echo "--"
                echo "#{getPrefix(src)}: #{env.numTasks} of #{env.totalTasks} tasks shown"


        getPadding = (items) ->
            ## We need one level of padding for each power of 10 $LINES uses.
            lines = String(items.length - 1)
            return lines.length


        _format = (items, padding, terms, postFilterRegexp) ->
            # Parameters:    items: todo items in padded array format
            #                padding: ITEM# number width; if empty auto-detects from $1 / $TODO_FILE.
            # Precondition:  None
            # Postcondition: env.numTasks and env.totalTasks contain statistics (unless env.TODOTXT_VERBOSE=0).

            ## Figure out how much padding we need to use, unless this was passed to us.
            padding ?= getPadding items

            items = items[1..]  # strip first PLACE_HOLDER
            nonemptyItems = []

            for item, i in items when /[\x21-\x7E]/.test item
                if item is TODO_PLACEHOLDER
                    # placeholder indicates starting listing of env.DONE_FILE
                    # number remaining items with zeros
                    stopNumbering = true
                else
                    if stopNumbering? then num = 0 else num = i + 1
                    nonemptyItems.push "#{zeroFill(num, padding)} #{item}"

            filters = filtercommand '', postFilterRegexp, terms

            filteredItems = []

            if filters.length
                filteredItems = applyFilters filters, nonemptyItems
            else
                filteredItems = nonemptyItems

            filteredItems = filteredItems.sort((a, b) ->
                k = padding + 1
                a = a[k..].toUpperCase()
                b = b[k..].toUpperCase()
                return if a <= b then -1 else 1)

            highlight = (colorVar) ->
                color = env[colorVar.toUpperCase()] ? env.PRI_X
                color = color.replace /\\+033/i, `'\033'`
                return color

            for item, i in filteredItems
                if /^[0-9]+ x/.test item
                    item = highlight('COLOR_DONE') + item + highlight('DEFAULT')
                if level = item.match(/^[0-9]+ \(([A-Z])\)/i)?[1]
                    item = highlight('PRI_' + level) + item + highlight('DEFAULT')
                filteredItems[i] = item

            for item, i in filteredItems
                item = item.replace env.HIDE_PROJECTS_SUBSTITUTION, ''
                item = item.replace env.HIDE_CONTEXTS_SUBSTITUTION, ''
                item = item.replace env.HIDE_PRIORITY_SUBSTITUTION, '$1'
                item = item.replace new RegExp(env.HIDE_CUSTOM_SUBSTITUTION, 'g'), ''

                filteredItems[i] = item

            echo item  for item in filteredItems

            if env.TODOTXT_VERBOSE > 0
                env.numTasks = filteredItems.length
                env.totalTasks = nonemptyItems.length

            if env.TODOTXT_VERBOSE > 1
                echo 'TODO DEBUG: Filters used were:'
                echo filters

            return filteredItems.length

        # == HANDLE ACTION ==
        action = action?.toLowerCase()

        if action == 'command'
            ## Get rid of "command" from arguments list
            argv.shift()
            ## Reset action to new first argument
            action = argv[0]?.toLowerCase()

        switch action
            when 'add', 'a'
                if not argv[1] and env.TODOTXT_FORCE is 0
                    input = read 'Add: '
                else
                    if not argv[1] then die "usage: #{env.TODO_SH} add \"TODO ITEM\""
                    argv.shift()
                    input = argv.join ' '
                _addto env.TODO_FILE, input

            when 'addm'
                if not argv[1] and env.TODOTXT_FORCE is 0
                    input = read 'Add: '
                else
                    if not argv[1] then die "usage: #{env.TODO_SH} addm \"TODO ITEM\""
                    argv.shift()
                    input = argv.join ' '

                # Treat each line separately
                for line in input.split '\n'
                    _addto env.TODO_FILE, line

            when 'addto'
                if not argv[1] then die "usage: #{env.TODO_SH} addto DEST \"TODO ITEM\""
                dest = "#{env.TODO_DIR}/#{argv[1]}"
                if not argv[2] then die "usage: #{env.TODO_SH} addto DEST \"TODO ITEM\""
                argv.shift()
                argv.shift()
                input = argv.join ' '

                if filesystem.load(dest)?
                    _addto dest, input
                else
                    die "TODO: Destination file #{dest} does not exist."


            when 'append', 'app'
                env.errmsg = "usage: #{env.TODO_SH} append ITEM# \"TEXT TO APPEND\""
                argv.shift(); item = argv.shift()
                todo = getTodo item

                if not argv[0] and env.TODOTXT_FORCE is 0
                    input = read 'Append: '
                else
                    input = argv.join ' '

                if env.SENTENCE_DELIMITERS.indexOf(input[0]) isnt -1
                    appendspace = ''
                else
                    appendspace = ' '

                input = cleaninput input

                newtodo = todo.replace /^.*/, "$&#{appendspace}#{input}"

                if todos = loadTodoFile env.TODO_FILE
                    todos[parseInt item, 10] = newtodo

                    if saveTodoFile todos, env.TODO_FILE
                        if env.TODOTXT_VERBOSE > 0
                            echo "#{item} #{newtodo}"
                    else
                        die "TODO: Error appending task #{item}."

            when 'archive'
                if todos = loadTodoFile()
                    # defragment blank lines
                    todos = (item for item in todos when item isnt '')
                    dones = (item for item in todos when /^x /.test item)

                    if env.TODOTXT_VERBOSE > 0 then echo item for item in dones

                    appendTodoFile dones, env.DONE_FILE
                    saveTodoFile (item for item in todos when not /^x /.test item)
                    echo "TODO: #{env.TODO_FILE} archived."

            when 'del', 'rm'
                # replace deleted line with a blank line when TODOTXT_PRESERVE_LINE_NUMBERS is 1
                env.errmsg = "usage: #{env.TODO_SH} del ITEM# [TERM]"
                item = argv[1]
                todo = getTodo item
                item = parseInt item, 10

                if not argv[2]
                    if env.TODOTXT_FORCE is 0
                        answer = read "Delete #{todo}? (y/n)"
                    else
                        answer = "y"
                    if answer is 'y'

                        todos = loadTodoFile()
                        todos[item] = ''

                        while todos[todos.length - 1] is ''
                            todos.length--

                        if env.TODOTXT_PRESERVE_LINE_NUMBERS is 0
                            # delete line (changes line numbers)
                            todos = (t for t in todos when t isnt '')

                        saveTodoFile todos

                        if env.TODOTXT_VERBOSE > 0
                            echo "#{item} #{todo}"
                            echo "TODO: #{item} deleted."
                    else
                        echo "TODO: No tasks were deleted."
                else
                    $3 = argv[2]
                    newtodo = todo.replace(new RegExp("^(\(.\) ){0,1} *#{$3} *", 'g'), '$1')
                                  .replace(new RegExp(" *#{$3} *$", 'g'), '')
                                  .replace(new RegExp("  *#{$3} *", 'g'), ' ')
                                  .replace(new RegExp(" *#{$3}  *", 'g'), ' ')
                                  .replace(new RegExp("#{$3}", 'g'), '')
                    if todo is newtodo
                          if env.TODOTXT_VERBOSE > 0 then echo "#{item} #{todo}"
                          die "TODO: '#{$3}' not found; no removal done."
                    else
                        todos = loadTodoFile env.TODO_FILE
                        todos[item] = newtodo
                        saveTodoFile todos, env.TODO_FILE
                    if env.TODOTXT_VERBOSE > 0
                        echo "#{item} #{todo}"
                        echo "TODO: Removed '#{$3}' from task."
                        echo "#{item} #{newtodo}"

            when 'depri', 'dp'
                env.errmsg = "usage: #{env.TODO_SH} depri ITEM#[, ITEM#, ITEM#, ...]"
                argv.shift()
                if argv.length is 0 then die env.errmsg

                # Split multiple space/comma separated do's into single comma separated list
                # Loop the 'depri' function for each item
                for item in argv.join(',').split(',')
                    todo = getTodo item

                    newtodo = todo.replace /^\(.\) /, ''
                    if newtodo isnt todo
                        todos = loadTodoFile env.TODO_FILE
                        todos[parseInt item, 10] = newtodo
                        saveTodoFile todos, env.TODO_FILE
                        if env.TODOTXT_VERBOSE > 0
                            echo "#{item} #{newtodo}"
                            echo "TODO: #{item} deprioritized."
                    else
                        echo "TODO: #{item} is not prioritized."

            when 'do'
                env.errmsg = "usage: #{env.TODO_SH} do ITEM#[, ITEM#, ITEM#, ...]"

                # shift so we get arguments to the do request
                argv.shift()
                if argv.length is 0 then die env.errmsg

                todos = loadTodoFile()

                # Split multiple space/comma separated do's into single comma separated list
                # Loop the 'do' function for each item
                for item in argv.join(',').split(',')
                    todo = getTodo item
                    # Check if this item has already been done
                    if todo?[0..1] != 'x '
                        now = formattedDate()
                        # remove priority once item is done
                        item = parseInt item, 10
                        todos[item] = todos[item].replace(/^\(.\) /, '')
                                                 .replace /^/, "x #{now} "
                        saveTodoFile todos
                        if env.TODOTXT_VERBOSE > 0
                            echo "#{item} #{todos[item]}"
                            echo "TODO: #{item} marked as done."
                    else
                        echo "TODO: #{item} is already marked done."

                if env.TODOTXT_AUTO_ARCHIVE is 1
                    root.run ['archive']

            when 'help'
                help()

            when 'shorthelp'
                shorthelp()

            when 'list', 'ls'
                argv.shift()  ## Was ls; new $1 is first search term
                _list env.TODO_FILE, argv

            when 'listall', 'lsa'
                argv.shift()  ## Was lsa; new $1 is first search term

                total = (loadTodoFile()?.length - 1) ? 0
                padding = String(total).length

                todoItems = loadTodoFile env.TODO_FILE
                doneItems = loadTodoFile env.DONE_FILE
                allItems = todoItems.concat doneItems

                _format allItems, padding, argv

                if env.TODOTXT_VERBOSE > 0
                    tdone = doneItems.length - 1

                    # temporarily suppress output
                    echo = () -> return

                    tasknum = _format todoItems, padding, argv
                    donenum = _format doneItems, padding, argv

                    # restore output
                    echo = ui.echo

                    echo "--"
                    echo "#{getPrefix(env.TODO_FILE)}: #{tasknum} of #{total} tasks shown"
                    echo "#{getPrefix(env.DONE_FILE)}: #{donenum} of #{tdone} tasks shown"
                    echo "total #{tasknum + donenum} of #{total + tdone} tasks shown"

            when 'listfile', 'lf'
                argv.shift() ## Was listfile, next $1 is file name
                if not argv[0]?
                    # nothing
                else
                    file = argv.shift() ## Was filename; next $1 is first search term

                    _list file, argv

            when 'listcon', 'lsc'
                file = loadSourceVarOrTodoFile()

                if contexts = file.match /(^|\s)@[\x21-\x7E]+/g
                    contexts = (context.trim() for context in contexts)
                    echo context for context in contexts.sort().unique()

            when 'listproj', 'lsprj'
                file = loadSourceVarOrTodoFile()
                argv.shift()
                filters = filtercommand '', '', argv
                file = applyFilters(filters, file.split('\n')).join('\n')

                if projects = file.match /(^|\s)\+[\x21-\x7E]+/g
                    projects = (project.trim() for project in projects)
                    echo project for project in projects.sort().unique()

            when 'listpri', 'lsp'
                argv.shift() ## was "listpri", new $1 is priority to list or first TERM
                if pri = argv[0]?.toUpperCase().match /^(([A-Z]\-[A-Z])|([A-Z]))$/ then pri = pri[0]; argv.shift() else pri = 'A-Z'
                _list env.TODO_FILE, argv, new RegExp('^ *[0-9]\+ \\([' + pri + ']\\) ')

            when 'prepend', 'prep'
                env.errmsg = "usage: #{env.TODO_SH} prepend ITEM# \"TEXT TO PREPEND\""
                replaceOrPrepend 'prepend', argv

            when 'pri', 'p'
                item = argv[1]
                newpri = argv[2]?.toUpperCase()

                env.errmsg = "usage: #{env.TODO_SH} pri ITEM# PRIORITY\n" +
                             "note: PRIORITY must be anywhere from A to Z."

                if argv.length isnt 3 then die env.errmsg
                if not /^[A-Z]/.test newpri then die env.errmsg

                todo = getTodo item

                oldpri = ''
                if /^\([A-Z]\) /.test todo
                    oldpri = todo[1]

                if oldpri isnt newpri
                    newtodo = todo.replace(/^\(.\) /, '').replace(/^/, "(#{newpri}) ")

                    if todos = loadTodoFile()
                        todos[parseInt item] = newtodo
                        saveTodoFile todos

                if env.TODOTXT_VERBOSE > 0
                    newtodo ?= todo
                    echo "#{item} #{newtodo}"
                    if oldpri isnt newpri
                        if oldpri
                            echo "TODO: #{item} re-prioritized from (#{oldpri}) to (#{newpri})."
                        else
                            echo "TODO: #{item} prioritized (#{newpri})."

                    if oldpri is newpri
                        echo "TODO: #{item} already prioritized (#{newpri})."

            when 'replace'
                env.errmsg = "usage: #{env.TODO_SH} replace ITEM# \"UPDATED ITEM\""
                replaceOrPrepend 'replace', argv

            when 'report'
                # archive first
                root.run ['archive']

                total = (loadTodoFile()?.length - 1) ? 0
                tdone = (loadTodoFile(env.DONE_FILE)?.length - 1) ? 0

                newdata = "#{total} #{tdone}"
                lastreport = filesystem?.load(env.REPORT_FILE)
                                       ?.trim()
                                       ?.split('\n')
                                       ?.pop()
                lastdata = lastreport.replace /^[^ ]+ /, ''

                if lastdata is newdata
                    echo lastreport
                    if env.TODOTXT_VERBOSE > 0 then echo "TODO: Report file is up-to-date."
                else
                    newreport = "#{formattedDate(true)} #{newdata}"
                    filesystem.append env.REPORT_FILE, newreport
                    echo "#{newreport}"
                    if env.TODOTXT_VERBOSE > 0 then echo "TODO: Report file updated."

            when 'deduplicate'
                todos = loadTodoFile()

                originalTaskNum = (t for t in todos when t isnt '').length - 1
                for item, i in todos
                    for dupe, d in todos when item is dupe and d > i
                        todos[d] = DUPE_PLACEHOLDER

                if env.TODOTXT_PRESERVE_LINE_NUMBERS is 0
                    todos = (t for t in todos when t isnt DUPE_PLACEHOLDER)
                else
                    for todo,i in todos when todo is DUPE_PLACEHOLDER
                        todos[i] = ''
                    while todos[todos.length - 1] is ''
                        todos.length--

                newTaskNum = (t for t in todos when t isnt '').length - 1
                deduplicateNum = originalTaskNum - newTaskNum
                if deduplicateNum is 0
                    echo "TODO: No duplicate tasks found"
                else
                    echo "TODO: #{deduplicateNum} duplicate task(s) removed"
                    saveTodoFile todos
            else
                usage()

        return 0

    root
