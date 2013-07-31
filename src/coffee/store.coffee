define 'store', ['jquery', 'localfile'], ($, localfile) ->
    todoHtmlPath = localfile.normalizedPath()
    innerHTML =  localfile.load(todoHtmlPath) or
                 window.document.documentElement.innerHTML

    $ ->
        # Strip todo data from DOM
        $body = $('body')
        bodyChildren = $('body > *')
        $(bodyChildren).detach()
        window.todotxt = $body.html()
        $body.empty()
        bodyChildren.appendTo($body)

    #  todo.html file structure:

    #  [markup]*
    #  [todo_1]
    #  [todo_2]
    #  ...
    #  [todo_n]
    #
    #  {four empty lines for visual separation}
    #
    #
    #  [enter] [store] [close] [markup]
    #
    #  * All html should be at end of file, but browser innerHTML have some
    #    markup shifted to the front (<html> to <body> elements).

    todoHtmlRegex = ///
        (<head>[\s\S]*<body>){0, 1}                   #1 markup
        ([\s\S]*)                                     #2 masterfile (usu. todos)
        (\n)*                                         #3 blank lines
        (^!!WARNING!{1}!.Do.not.edit.this.line.[^{]*) #4 enter
        ([\s\S]*)                                     #5 store
        (!!ENDSTORE!{1}![\s\S]*$)                     #6 close, markup
    ///m

    matches = innerHTML.match todoHtmlRegex
    store = JSON.parse matches[5] or {}
    store.files = store.files or {}
    store.settings = store.settings or {}
    if store.settings['masterfile']
        store.files[store.settings['masterfile']] = matches[2]

    load = ->
        store

    save = ->
        masterfileContents = store.files[store.settings['masterfile']] || ''
        masterfileContents = masterfileContents.replace /\$/g, '$$$$'
        tmp = store.files[store.settings['masterfile']]
        delete store.files[store.settings['masterfile']]
        jsonStr = JSON.stringify(store)
        jsonStr = jsonStr.replace  /\$/g, '$$$$'
        store.files[store.settings['masterfile']] = tmp

        if oldContents = localfile.load todoHtmlPath
            matches = oldContents.match todoHtmlRegex
            newContents = oldContents.replace todoHtmlRegex, "$1#{masterfileContents}$3$4#{jsonStr}$6"
            if not localfile.save todoHtmlPath, newContents
                console.error "store error: can't write to: " + todoHtmlPath
        else
            console.error "store error: can't read from: " + todoHtmlPath

    get = (key) ->
        # return clone of data
        $.extend(true, {}, store)[key]

    set = (key, value) ->
        store[key] = value
        @save store

    {
        load,
        save,
        get,
        set
    }
