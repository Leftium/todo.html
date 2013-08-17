# todo.html os emulation layer

define 'os', ['localfile', 'store'], (localfile, store) ->
    env = {}

    ui =
        echo: console.log
        ask: window.prompt

    system =
        db: (msg, tag) ->
            if not tag? then return console.log msg
            for tagRe in (db.tags ? []) when tagRe.test tag
                return console.log msg

        exit: (status) ->
            throw 'OS exit with status: ' + status

    system.db.tags = [/tag/]

    fs =
        lastFilePath: '',

        load:  (filepath) ->
            @lastFilePath = filepath
            if matches = filepath.match(/(^#.*)/)
                filename = matches[1]
                files = store.get('files') or {}
                files[filename] or null
            else
                localfile.load filepath

        save: (filepath, content) ->
            if matches = filepath.match(/(^#.*)/)
                filename = matches[1]
                files = store.get('files') or {}
                files[filename] = content
                store.set 'files', files
            else
                localfile.save filepath, content

        append: (filepath, appendContent) ->
            if content = @load filepath
                content += appendConent + '\n'
                if @save filepath, content
                    return content

    return { env, fs, ui, system }
