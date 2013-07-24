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

    load = ->
        JSON.parse innerHTML.replace(todoHtmlRegex, '$3')

    save = (store) ->
        jsonStr = JSON.stringify(store)
        if oldContents = localfile.load localfile.normalizedPath()
            newContents = oldContents.replace todoHtmlRegex, "$1$2#{jsonStr}$4"
            localfile.save localfile.normalizedPath(), newContents

    {
        load: load,
        save: save
    }
