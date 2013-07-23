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

    reStore = new RegExp(
        '([\\s\\S]*!!' + 'WARNING!! Do not edit this line. \\(' +
        'https://github.com/Leftium/todo.html\\))' +
        '([\\s\\S]*)(!!END' + 'STORE!![\\s\\S]*$)', 'm')

    load = ->
        JSON.parse innerHTML.replace(reStore, '$2'), '$2'


    save = (store) ->
        jsonStr = JSON.stringify(store)
        if oldContents = localfile.load normalizedPath()
            newContents = oldContents.replace reStore, '$1       ' + jsonStr + '$3'
            localfile.save normalizedPath(), newContents

    {
        normalizedPath: normalizedPath,
        load: load,
        save: save
    }
