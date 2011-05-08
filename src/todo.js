var DEBUG = false;

// Utility method to join variables and strings
function zip() {
    return Array.prototype.slice.call(arguments).join(' ');
}

// Write DOM to file
function saveDomToFile(filepath)
{
    if (typeof(filepath) == 'undefined')
    {
        // Default to the file itself if no other filepath given
        filepath = $.twFile.convertUriToLocalPath(location.toString());
    } else {
        // Normalize filepath:
        // Strip space, tab, from beginning.
        // Strip space, tab, backslash, slash from end.
        filepath = filepath.match(/^[ \t]*(.*?)[ \t\\\/]*$/)[1];

        // Check if path ommitted; only filename given
        if (filepath.search(/\\|\//) == -1)
        {
            // Prepend working directory if only filename given.
            // Otherwise default twFile path is in an odd place.

            // Get the current file
            var path = $.twFile.convertUriToLocalPath(location.toString());

            // Strip filename off
            path = path.match(/^(.*[\\\/]).*?$/)[1];

            filepath = path + filepath;
        }
    }

    var localPath = $.twFile.convertUriToLocalPath(location.toString());
    var original = $.twFile.load(localPath);
    var posDiv = locateStoreArea(original);

    if (posDiv) {
        var revised = original.substr(0,posDiv[0] + startSaveArea.length) +
                      "\n" + store.html() + "\n" + original.substr(posDiv[1]);
        return $.twFile.save(filepath, revised);
    } else {
        return null;
    }
}

// Map of key-value pairs
// Stored in HTML DOM inside #store <div>
function Store()
{
    var $store = $('#storeArea');
    var map = {};

    $store.find('pre').each(function() {
        map[this.id] = $(this).text();
    });

    this.get = function(key) {
        return map[key];
    }

    this.getAll = function() {
        return map;
    }

    this.set = function(key, value) {
        map[key] = value;

        $key = $store.find('#' + key);

        if ($key.length == 0) {
            $store.append('<pre id="' + key + '">' + value + '</pre>\n');
        } else {
            $key.text(value);
        }
        // saveDomToFile();
        return value;
    }

    this.html = function() {
        return $.trim($store.html()).replace(/<\/pre><pre/gi, '</pre>\n<pre');
    }
}

function CliOutput($jqObject)
{
    this.$scrollPadding = $jqObject.children('#scroll-padding');
    this.commandCount = 0;

    this.addText = function(newText) {
        this.commandCount++;
        newText = newText.replace(/</g, '&lt;');
        newText = newText.replace(/>/g, '&gt;');
        newText = newText.replace(/ /g, '&nbsp;');
        newText = newText.replace(/\n/g, '<br />');
        this.$scrollPadding.before('<div id="MARK_' + this.commandCount + '">' + newText + '</div>');
    }

    this.clear = function() {
        $jqObject.children(':not(#scroll-padding)').remove();
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

}

// Maintains command history.
function CommandTextArea(jqObject)
{
    /// Public Members ///

    this.add = function(command) {
       var tmpHistory = _getHistory();

       // Remove command from history
       tmpHistory = $.grep(tmpHistory, function (c) { return c != command; });

       tmpHistory.splice(tmpHistory.length - 1, 0, command);

       // Limit history length
       if (tmpHistory.length > 100) {
           tmpHistory.splice(0, tmpHistory.length - 100 - 1);
       }

       place = tmpHistory.length - 1;

       _setHistory(tmpHistory);
    }

    this.clear = function() {
        jqObject.val('');
    }

    this.traverseHistory = function(goingUp) {
        if (goingUp) {
            place = Math.max(place - 1, 0);
        } else {
            place = Math.min(place + 1, _getHistory().length - 1);
        }
        jqObject.val(_getHistory()[place]);
    }

    this.getHistory = function() {
        // Leave off last "blank" history item.
        return _getHistory().slice(0, _getHistory().length - 1);
    }

    /// Private Members ///
    var _getHistory = function()
    {
        return store.get('_HISTORY').split(/\r\n|\r|\n/);
    }

    var _setHistory = function(newHistory)
    {
        return store.set('_HISTORY', newHistory.join('\n'));
    }

    var place = _getHistory().length - 1;
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

    // IE does not give the correct scrollHeight on the first call
    $.fn.scrollHeight = function() {
        this[0].scrollHeight;
        return this[0].scrollHeight;
    };

    window.store = new Store();

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
            if (args.length == 1) {
                 asdf
             } else if (args.length == 2) {
                store.set(args[0], args[1]);
            }
        } else {
            // default to JavaScript
            result += doJavaScript(command);
        }
        return result  ;
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
        printLn('INITIALIZED! Using driver:' + $.twFile.getDriver().name);
    });
});

