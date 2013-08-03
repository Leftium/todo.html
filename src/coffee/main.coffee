# In-browser todo.txt REPL
# http://github.com/Leftium/todo.html
#
# written by John-Kim Murphy
#
#
# based on:
#   https://github.com/larryng/coffeescript-repl

require [
    'version',
    'jquery',
    'coffee-script',
    'nodeutil',
    'store',
    'os',
    'todo',
    'shellwords',
], (
    version,
    $,
    CoffeeScript,
    nodeutil,
    store,
    os,
    todo,
    shellwords
) ->

  $ ->
    SAVED_CONSOLE_LOG = console.log

    $output    = $('#output')
    $input     = $('#input')
    $prompt    = $('#prompt')
    $inputdiv  = $('#inputdiv')
    $inputl    = $('#inputl')
    $inputr    = $('#inputr')
    $inputcopy = $('#inputcopy')


    escapeHTML = (s) ->
      s.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');


    class TodoREPL
      DEFAULT_SETTINGS =
        lastVariable: '$_'
        maxLines: 500
        maxDepth: 2
        showHidden: false
        colorize: true

      constructor: (@output, @input, @prompt, settings={}) ->
        @history = store.get 'history'
        @historyi = -1
        @saved = ''
        @multiline = false

        @settings = $.extend({}, DEFAULT_SETTINGS)

        if localStorage and localStorage.settings
          for k, v of JSON.parse(localStorage.settings)
            @settings[k] = v

        for k, v of settings
          @settings[k] = v

        @input.keydown @handleKeypress

      resetSettings: ->
        localStorage.clear()

      saveSettings: ->
        localStorage.settings = JSON.stringify($.extend({}, @settings))

      print: (args...) =>
        s = args.join(' ') or ' '
        o = @output[0].innerHTML + s + '\n'
        @output[0].innerHTML = o.split('\n')[-@settings.maxLines...].join('\n')
        undefined

      processSaved: =>
        argv = shellwords.split(@saved)
        if argv[0] in ['todo', 'td', 't']
            @saved = ''
            output = todo.run argv[1..]
        else
            try
                if CoffeeScript.compile?
                    compiled = CoffeeScript.compile @saved
                    compiled = compiled[14...-17]
                else
                    compiled = @saved  #  JavaScript
                value = eval.call window, compiled
                window[@settings.lastVariable] = value
                output = nodeutil.inspect value, @settings.showHidden, @settings.maxDepth, @settings.colorize
            catch e
              if e.stack
                output = e.stack

                # FF doesn't have Error.toString() as the first line of Error.stack
                # while Chrome does.
                if output.split('\n')[0] isnt e.toString()
                    output = "#{e.toString()}\n\nStack trace:\n#{e.stack}"
                output = output.replace /file.*\//g, ''
              else
                output = e.toString()
        @saved = ''
        @print output.split('\n')[0]

      setPrompt: =>
        s = if @multiline then '----' else 'todo'
        @prompt.html "#{s}&gt;&nbsp;"

      addToHistory: (s) =>
        @history.unshift s
        store.set 'history', @history
        @historyi = -1

      addToSaved: (s) =>
        @saved += if s[...-1] is '\\' then s[0...-1] else s
        @saved += '\n'
        @addToHistory s

      clear: =>
        @output[0].innerHTML = ''
        undefined

      handleKeypress: (e) =>
        switch e.which
          when 13
            e.preventDefault()
            input = @input.val()
            @input.val ''

            @print @prompt.html() + escapeHTML(input)

            if input
              @addToSaved input
              if input[...-1] isnt '\\' and not @multiline
                @processSaved()

          when 27
            e.preventDefault()
            input = @input.val()

            if input and @multiline and @saved
              input = @input.val()
              @input.val ''

              @print @prompt.html() + escapeHTML(input)
              @addToSaved input
              @processSaved()
            else if @multiline and @saved
              @processSaved()

            @multiline = not @multiline
            @setPrompt()

          when 38
            e.preventDefault()

            if @historyi < @history.length-1
              @historyi += 1
              @input.val @history[@historyi]

          when 40
            e.preventDefault()

            if @historyi > 0
              @historyi += -1
              @input.val @history[@historyi]


    resizeInput = (e) ->
      width = $inputdiv.width() - $inputl.width()
      content = $input.val()
      content.replace /\n/g, '<br/>'
      $inputcopy.html content

      $inputcopy.width width
      $input.width width
      $input.height $inputcopy.height() + 2


    scrollToBottom = ->
      window.scrollTo 0, $prompt[0].offsetTop


    init = ->

      # bind other handlers
      $input.keydown scrollToBottom

      $(window).resize resizeInput
      $input.keyup resizeInput
      $input.change resizeInput

      $('html').click (e) ->
        if e.clientY > $input[0].offsetTop
          $input.focus()

      # instantiate our REPL
      repl = new TodoREPL $output, $input, $prompt

      # replace console.log
      console.log = (args...) ->
        SAVED_CONSOLE_LOG.apply console, args
        repl.print args...

      # expose repl as $$
      window.$$ = repl

      # make font visible
      $('body').css('opacity', 1)

      # initialize window
      resizeInput()
      $input.focus()

      document.title = "todo.html v#{version}"

      window.version = () ->
          repl.print """
            <b>todo.html by <a href=http://leftium.com>john-kim murphy</a></b>
            v#{version} | based on <a href=http://todotxt.com>idea</a> by <a href=http://ginatrapani.org>gina trapani</a> | <a href=http://www.gnu.org/copyleft/gpl.html>gpl license</a> | <a href=https://github.com/Leftium/todo.html>fork me on github</a>!

          """

      # help
      window.help = ->
        repl.print """
          <strong>Features</strong>
          <strong>========</strong>
          + Built-in JavaScript interpreter.
          + <strong>[Esc]</strong> toggles multiline mode.
          + <strong>[Up]/[Down] arrow</strong> flips through line history.
          + <strong>#{repl.settings.lastVariable}</strong> stores the last returned value.
          + Access the internals of this console through <strong>$$</strong>.
          + <strong>$$.clear()</strong> clears this console.

          <strong>Settings</strong>
          <strong>========</strong>
          You can modify the behavior of this REPL by altering <strong>$$.settings</strong>:

          + <strong>lastVariable</strong> (#{repl.settings.lastVariable}): variable name in which last returned value is stored
          + <strong>maxLines</strong> (#{repl.settings.maxLines}): max line count of this console
          + <strong>maxDepth</strong> (#{repl.settings.maxDepth}): max depth in which to inspect outputted object
          + <strong>showHidden</strong> (#{repl.settings.showHidden}): flag to output hidden (not enumerable) properties of objects
          + <strong>colorize</strong> (#{repl.settings.colorize}): flag to colorize output (set to false if REPL is slow)

          <strong>$$.saveSettings()</strong> will save settings to localStorage.
          <strong>$$.resetSettings()</strong> will reset settings to default.

        """

      os.ui.echo = repl.print
      todo.init store.get('env') or {}, os.fs, os.ui, os.system

      # print header
      @version()
      repl.print 'Welcome! `todo ls +basics` starts a product tour.'

    init()
