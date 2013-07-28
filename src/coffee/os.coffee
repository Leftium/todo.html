# todo.html os emulation layer

define 'os', ['localfile'], (localfile) ->
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
        load: (filepath) ->
            return localfile.load filepath

        save: (filepath, content) ->
            return localfile.save filepath, content

        append: (filepath, appendContent) ->
            if content = @load filepath
                content += appendConent + '\n'
                if @save filepath, content
                    return content

    return { env, fs, ui, system }
