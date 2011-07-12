var DEBUG = false;

// Utility method to join variables and strings
function zip() {
    return Array.prototype.slice.call(arguments).join(' ');
}

function normalizedFilepath(filepath) {
    if (filepath === undefined) {
        // Default to the file itself if no other filepath given
        filepath = $.twFile.convertUriToLocalPath(location.href);
    } else {

        // Strip space, tab, from beginning.
        // Strip space, tab, backslash, slash from end.
        filepath = filepath.match(/^[ \t]*(.*?)[ \t\\\/]*$/)[1];

        // Check if absolute path
        if (filepath.search(/^([a-z]:)?[\/\\]/i) == -1)
        {
            // Prepend working directory to relative path/bare filename.
            // (Otherwise default twFile path is in an odd place.)

            // Get the current file
            var path = $.twFile.convertUriToLocalPath(location.href);

            // Strip filename off
            path = path.match(/^(.*[\\\/]).*?$/)[1];

            filepath = path + filepath;
        }
    }
    return filepath;
}

store = (function() {
    // only load "static" variables once
    var $store = $('#store-area');
    var map = {};

    $store.find('pre').each(function() {
        map[this.id] = TAFFY.JSON.parse($(this).text());
    });

    return {
        get: function(name) {
            if (name.match(/^(#|\$|\*)/)) {
                // TODO: reload file if too much time has passed
                return map[name];
            } else {
                return $.twFile.load(normalizedFilepath(name));
            }
        },

        set: function(name, value) {
            if (name.match(/^(#|\$|\*)/)) {
                map[name] = value;
                // TODO: delayed, less frequent saving
                $.twFile.save(normalizedFilepath(), updatedHtml());
            }  else {
                $.twFile.save(normalizedFilepath(name), value.toString())
            }
            return value;
        },

        list: function() {
            return map;
        },

        remove: function(name) {
            delete map[name];
            $.twFile.save(normalizedFilepath(), updatedHtml());
        },

        html: function() {
              var $div = $('<div />');

              $.each(map, function(key, value) {
                  $('<pre />')
                  .attr('id', key)
                  .html(TAFFY.JSON.stringify(value))
                  .appendTo($div);
              });

              return $.trim($div.html()
                         .replace(/PRE/g, 'pre')
                         .replace(/<\/pre><pre/g, '</pre>\n<pre')
                     );
        }

    };

})();

// Get html with updated #store-area from DOM
updatedHtml = function() {
    var localPath = normalizedFilepath();
    var original = $.twFile.load(localPath);
    var posDiv = locateStoreArea(original);

    if (posDiv) {

        return original.substr(0, posDiv[0] + startSaveArea.length) +
               '\n' + store.html() + '\n' + original.substr(posDiv[1]);
    } else {
        return null;
    }
}

function CliOutput($jqObject)
{
    this.addText = function(newText) {
        this.commandCount++;

        newText = newText.replace(/ /g, '&nbsp;')
                      .replace(/\t/g, '&nbsp;&nbsp;&nbsp;&nbsp;')
                      .replace(/</g, '&lt;')
                      .replace(/>/g, '&gt;')
                      .replace(/\n/g, '<br />');

        $('<div />')
            .attr('id', 'MARK_' + this.commandCount)
            .html(newText)
            .insertBefore(this.$scrollPadding);
    }

    this.clear = function() {
        $jqObject.children(':not(#scroll-padding)').remove();
        this.commandCount = 0;
        this.addText('');
        this.setMark();
    }

    this.setMark = function() {
        this.mark = 'MARK_' + this.commandCount;
    }

    this.gotoMark = function() {
        var target_position = $('#'+this.mark).position();
        var target_top = target_position.top + $('#cli-output').scrollTop();

        $('#cli-output').animate({scrollTop:target_top}, 200);
    }

    this.page = function (isPageUp) {
        var scrollDistance = (isPageUp ? -1 : 1);
        scrollDistance *= $jqObject[0].clientHeight - 3*lineHeight;

        $jqObject.scrollTop($jqObject.scrollTop() + scrollDistance);
    }

    // Calculate how tall the textarea font is using a dummy div
    var lineHeight = function () {
        var ta = $('<div rows=1 id=remove-me>TEST DIV</div>');
        $jqObject.children('#scroll-padding').append(ta);

        var height = ta.height();
        $('#remove-me').empty();
        return height;
    }();

    this.$scrollPadding = $jqObject.children('#scroll-padding');
    this.clear();
}

// Maintains command history.
function CommandTextArea(jqObject)
{
    /// Public Members ///

    this.add = function(command) {
       var tmpHistory = store.get('*history');

       // Remove command from history
       tmpHistory = $.grep(tmpHistory, function (c) { return c != command; });

       tmpHistory.splice(1, 0, command);

       // Limit history length
       if (tmpHistory.length > 100) {
           tmpHistory.splice(0, tmpHistory.length - 100 - 1);
       }

       place = 0;

       store.set('*history', tmpHistory);
    }

    this.clear = function() {
        jqObject.val('');
    }

    this.traverseHistory = function(goingUp) {
        if (goingUp) {
            place = Math.max(place - 1, 0);
        } else {
            place = Math.min(place + 1, store.get('*history').length);
        }
        jqObject.val(store.get('*history')[place]);
    }

    this.getHistory = function() {
        // Leave off last "blank" history item.
        var fullHistory = store.get('*history');
        return fullHistory.slice(1, fullHistory.length);
    }

    // Ensure history exists in store
    if (store.get('*history') === undefined) {
        store.set('*history', [''])
    }

    var place = 0;
}

function getText(id)
{
    return $('#' + id).text();
}

function doJavaScript(jsString)
{
    var results = '';

    try {
        results = eval(jsString);
    } catch(err) {
        for(var key in err) {
            results += key + ": " + err[key] + "\n";
        }
    }

    if (typeof results == 'undefined') {
        results = 'UNDEFINED';
    } else if (results == null) {
        results = 'NULL';
    } else {
        results = results.toString();
    }
    return results;
}

// Run on document ready
$(function() {
    var $ = jQuery; // local alias

    var cliOutput = new CliOutput($('#cli-output'));
    cliOutput.addText(document.title + '\n\n' +
                           getText('usage') + '\n');
    cliOutput.setMark();

    // Expose ability to print from command line
    window.printLn = function(text) {
        cliOutput.addText(text);
    }

    function doCommand(command) {
        var result = '';
        var match  = command.match(/^\s*([^\s]+)\s*(.*)/)
        var action = '';
        var args   = '';

        if (match && match[1] && (action = match[1].toLowerCase()) &&
                     match[2] && (args   = match[2])) {
            void(0);
        }

        if (DEBUG) {
            result = 'action    = ' + action + '\n' +
                     'args      = ' + args +   '\n';
        }

        if (action == 'h') {
            result += getText('usage') + '\n\n' + getText('shorthelp');

        } else if (action == 'help') {
            result += getText('usage') + '\n\n' + getText('help');

        } else if (action == 'clear' ||
                   action == 'clr'   ||
                   action == 'c') {
            cliOutput.clear();

        } else if (action == 'js' || action == 'j') {
            result += doJavaScript(args);

        } else if (action == 'history' ||
                   action == 'hi') {
            result += commandTextArea.getHistory().join('\n');

        } else if (action == 'set' ||
                   action == 's') {
            // TODO: fix: args is a string, not an array
            var setArgs = $.trim(args).match(/([^ \t]*)[ \t]*(.*)/);

            /*
            if (setArgs) {
                printLn(setArgs.length.toString());
                $.each(setArgs, function (i, v) {
                    printLn('[' + v + ']');
                });
            } else {
                printLn(args);
            }
            */

            if (setArgs[1] == '') {
                // list all values
                $.each(store.list(), function(key, value) {
                                         if (key.match(/^\$/)) {
                                             printLn(key.substr(1) + '=' + value);
                                         }
                                     });
            } else {
                if (setArgs[2] == '') {
                    // list single value
                    printLn(setArgs[1] + '=' + store.get('$' + setArgs[1]));
                } else {
                    store.set('$' + setArgs[1], setArgs[2]);
                }
            }

        } else if (action == 'unset' ||
                   action == 'u') {
            store.remove('$' + args);

        } else if (action == 'dir' ||
                   action == 'd') {
            $.each(store.list(), function(key, value) {
                                     if (key.match(/^\#/)) {
                                         printLn(key);
                                     }
                                 });

        } else {
            // default to JavaScript
            result += doJavaScript(command);
        }
        return result;
      }

    var commandTextArea = new CommandTextArea($('#cli-input'));
    window.cta = commandTextArea;

    // Input textarea gets the default focus
    $('#cli-input').focus();

    // Intercept newlines in #command <textarea>
    $('#cli-input').keypress(function(e) {
        return (e.which != 13);
    });

    // Some keys have a special purpose:
    $('#cli-input').keydown(function(e) {
        switch (e.which) {
          case 13: // return
            var command = $.trim($('#cli-input').val());
            if (command == '') {
                // Snap to beginning of last output
                cliOutput.gotoMark();
                commandTextArea.clear();
            } else {
                commandTextArea.add(command);

                cliOutput.addText('>' + command);
                cliOutput.setMark();

                cliOutput.addText(doCommand(command));

                commandTextArea.clear();
                cliOutput.gotoMark();
                $('#cli-input').focus();
            }
            break;

          case 33: // page up
          case 34: // page down
            cliOutput.page(e.which == 33);
            break;

          case 38: // up
          case 40: // down
            commandTextArea.traverseHistory(e.which == 38);
            break;

          case 27: // esc
            commandTextArea.clear();
            break;

          default:
            return true;
            break;
       }
       return false;
    });

    $.twFile.initialize().then(function() {
        printLn('\nINITIALIZED! Using driver: ' + $.twFile.getDriver().name);
        printLn('Filepath: ' + normalizedFilepath() + '\n\n');

        // process todo.cfg here
        printLn('Processing: ' + normalizedFilepath('todo.cfg'));

        var contents = $.twFile.load(normalizedFilepath('todo.cfg'));
        printLn(processTodoCfg(contents).join('\n'));
    });
});

// This method roughly emulates how Bash would process todo.cfg: ignore
// #comments and process export commands. I know it is not perfect, but
// it should work satisfactorily for "well-formed" config files.

function processTodoCfg(todoFileContents) {
    var results = [];

    function processTodoCfgLine(line)
    {
        // ignore #comments
        line = line.replace(/#.*/, '');

        var exportArgs = line.match(/export\s+(.*)=(.*)/);
        if (exportArgs) {
            var name = exportArgs[1];
            var value = exportArgs[2];

            // Emulate Bash `dirname "$0"`
            // Get the current path sans filename
            var path = $.twFile.convertUriToLocalPath(location.href);
            path = path.match(/^(.*)[\\\/].*?$/)[1];

            value = value.replace(/`\s*dirname\s+['"]\$0['"]\s*`/, path);

            // Strip (single) quotes from beginning and end
            value = value.match(/^["']*(.*?)["']*$/)[1];


            // Substitute $environment_variables
            var variables = value.match(/\$[a-zA-Z_][a-zA-Z0-9_]*/g);

            if (variables) {
                $.each(variables, function(i, varName) {
                    var re = new RegExp('\\' + varName, 'g');
                    value = value.replace(re, store.get(varName) || '');
                });
            }
            store.set('$' + name, value);
            results.push(name + ' = ' + value);
        }
    }

    var lines = todoFileContents.split('\n');

    $.each(lines, function(i, v) {
        processTodoCfgLine(v);
    });

    return results;
}

