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

    normalizedPath = (filepath) ->
        if !filepath
            # Default to the file itself if no other filepath given.
            filepath = localfile.convertUriToLocalPath location.href
        else
            # Strip space, tab, from beginning.
            # Strip space, tab, backslash, slash from end.
            filepath = filepath.match(/^[ \t]*(.*?)[ \t\\\/]*$/)[1];

            # Check if absolute path
            if filepath.search(/^([a-z]:)?[\/\\]/i == -1)
                # Prepend working directory to relative path/bare filename.
                # (Otherwise default twFile path ends up in odd places.)

                # Get the current file
                path = localfile.convertUriToLocalPath location.href

                # Strip filename off
                path = path.match(/^(.*[\\\/]).*?$/)[1]

                filepath = path + filepath

            filepath = filepath.replace(/\//g, '\\')

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
        ([\s\S]*)                                   #1 markup, todos, blanks
        (^!!WARNING!!.Do.not.edit.this.line.[^{]*)  #2 enter
        ([\s\S]*)                                   #3 store
        (!!ENDSTORE!![\s\S]*$)                      #4 close, markup
    ///m

    load = ->
        JSON.parse innerHTML.replace(todoHtmlRegex, '$3')

    save = (store) ->
        jsonStr = JSON.stringify(store)
        if oldContents = localfile.load normalizedPath()
            newContents = oldContents.replace todoHtmlRegex, "$1$2#{jsonStr}$4"
            localfile.save normalizedPath(), newContents

    {
        normalizedPath: normalizedPath,
        load: load,
        save: save
    }
