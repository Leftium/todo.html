define 'store', ['jquery', 'localfile'], ($, localfile) ->
    innerHTML = window.document.documentElement.innerHTML

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
        ([\s\S]*)                                     #1 markup, todos, blanks
        (^!!WARNING!{1}!.Do.not.edit.this.line.[^{]*) #2 enter
        ([\s\S]*)                                     #3 store
        (!!ENDSTORE!{1}![\s\S]*$)                     #4 close, markup
    ///m

    store = JSON.parse innerHTML.replace(todoHtmlRegex, '$3')

    load = ->
        store

    save = ->
        jsonStr = JSON.stringify(store)
        filepath = localfile.normalizedPath()
        if oldContents = localfile.load filepath
            newContents = oldContents.replace todoHtmlRegex, "$1$2#{jsonStr}$4"
            if not localfile.save filepath, newContents
                console.error "store error: can't write to: " + filepath
        else
            console.error "store error: can't read from: " + filepath

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
