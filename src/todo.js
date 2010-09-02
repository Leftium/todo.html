var DEBUG = false;
var PADDING_ON = false;

// Utility method to join variables and strings
function zip() {
    return Array.prototype.slice.call(arguments).join(' ');
}

// Strip whitespace from start and end;
// Strip '\' and '/' from end of filepath.
function cleanPath(str)
{
    var start = 0;
    var end   = str.length - 1;

    while((start < end) && ' \t'.indexOf(str[start]) != -1) start++;
    while((start < end) && ' \t\\/'.indexOf(str[end]) != -1) end--;

    return str.substring(start, end + 1);
}

// Write DOM to file
function saveDomToFile(filepath)
{
    // Default to the file itself if no other filepath given
    if (typeof(filepath) == 'undefined')
    {
        // Get the current file
        var location_href = document.location.href;
        // Convert the path to a readable format
        filepath = $.twFile.convertUriToLocalPath(location_href);
    } else {
        filepath = cleanPath(filepath);

        // Check if no path; only filename given
        if (filepath.indexOf('\\') == -1 &&
            filepath.indexOf('/')  == -1)
        {
            // Prepend the current path //

            // Get the current file
            var location_href = document.location.href;
            // Convert the path to a readable format
            var path = cleanPath($.twFile.convertUriToLocalPath(location_href));

            var endOfPath = Math.max(path.lastIndexOf('\\'),
                                     path.lastIndexOf('/'));

            path = path.substring(0, endOfPath + 1);

            filepath = path + filepath;
        }
    }

    // Can't get doctype from Javascript/DOM.
    // This needs to match actual HTML doctype.
    var doctype = '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">\n';

    var $htmlClone = $('html').clone();

    $htmlClone.find('#removeme').remove();
    $htmlClone.find("applet[name='TiddlySaver']").remove();
    var text = $htmlClone.attr('outerHTML');

    if (text === undefined) {
        text = new XMLSerializer().serializeToString($htmlClone[0]);
    }

    text = doctype + text;

    return $.twFile.save(filepath, text);
}

// Map of key-value pairs
// Stored in HTML DOM inside #store <div>
function Store()
{
    var $store = $('#store');
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
        return $store.html();
    }
}

// Encapsulates functionality to display text output to a <textarea>
function OutputTextArea(jqObject)
{
    /// Public Members ///

    this.setText = function(text) {
        jqObject.val(text + padding());
    }

    this.addText = function(newText) {
        if (newText != '') newText += '\n';

        var origText = jqObject.val();
        // Replace padding with newText
        var re = new RegExp('((PADDING:\\d*)*\\n){' + paddingLines +
                            '}(END| |~)$');
        newText = origText.replace(re, newText);
        this.setText(newText);
    }

    this.setMark = function() {
        markScrollHeight = jqObject.scrollHeight() - lineHeight;
    }

    this.gotoMark = function () {
        jqObject.scrollTop(markScrollHeight - markPadding);
    }

    this.page = function (isPageUp) {
        var scrollDistance = (isPageUp ? -1 : 1);
        scrollDistance *= jqObject[0].clientHeight - 3*lineHeight;

        jqObject.scrollTop(jqObject.scrollTop() + scrollDistance);
    }


    /// Private Members ///

    // Calculate how tall the textarea font is using a dummy textarea
    var lineHeight = function () {
        var ta = $('<textarea rows=1 id=removeme></textarea>');
        $('body').append(ta);

        ta.val('\n');
        var oldHeight = ta.scrollHeight();
        ta.val('\n\n');
        var newHeight = ta.scrollHeight();

        $('#removeme').empty();
        return newHeight - oldHeight;
    }();

    // Returns string of newlines used to force <textarea>'s
    // scrollHeight to increase when a line is added. Also allows
    // scrolling text to top even if textarea is not filled, yet.
    // Computes a new string every time, in case the textarea was
    // resized.
    var padding = function() {
        var ret    = (PADDING_ON ? 'END' : ' ');

        paddingLines = Math.floor(jqObject[0].clientHeight /
                                  lineHeight);
        markPadding  = paddingLines * lineHeight;

        for (var i = 0; i < paddingLines; i++) {
            ret = (PADDING_ON ? 'PADDING:' + (i+1) : '') + '\n' + ret;
        }
        return ret;
    };

    var markPadding;
    var markScrollHeight;
    // Number of newlines in padding string. Automatically updated
    // when padding() constructs padding string.
    var paddingLines = 0;

    this.setMark();
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
        return store.get('_HISTORY').split('\n');
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

function test()
{
var originalPath = document.location.toString();
    var localPath = getLocalPath(originalPath);

    var original = loadOriginal(localPath);
    print(localPath);
    // print(original);

    var posDiv = false;

    var revised = updateOriginal(original,posDiv,localPath);

    print(revised);
}

// Run on document load
$(window).load(function() {
    var $ = jQuery; // local alias

    // IE does not give the correct scrollHeight on the first call
    $.fn.scrollHeight = function() {
        this[0].scrollHeight;
        return this[0].scrollHeight;
    };

    window.store = new Store();

    var outputTextArea = new OutputTextArea($('#output'));
    outputTextArea.setMark();
    outputTextArea.setText(document.title + '\n\n' +
                           getText('usage') + '\n');

    // Expose ability to print from command line
    window.print = function(text) {
        outputTextArea.addText(text);
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
            outputTextArea.setText('');

        } else if (action == 'js' || action == 'j') {
            result += doJavaScript(args);

        } else if (action == 'history' ||
                   action == 'hi') {
            result += commandTextArea.getHistory().join('\n');

        } else {
            // default to JavaScript
            result += doJavaScript(command);
        }

        return result;
    }

    var commandTextArea = new CommandTextArea($('#command'));

    // Input textarea gets the default focus
    $('#command').focus();

    // Intercept newlines in #command <textarea>
    $('#command').keypress(function(e) {
        return (e.which != 13);
    });

    // Some keys have a special purpose:
    $('#command').keydown(function(e) {
        switch (e.which) {
          case 13: // return
            var command = $.trim($('#command').val());
            if (command == '') {
                // Snap to beginning of last output
                outputTextArea.gotoMark();
                commandTextArea.clear();
            } else {
                commandTextArea.add(command);

                outputTextArea.setMark();
                outputTextArea.addText('>' + command);
                outputTextArea.addText(doCommand(command));

                // Delay to ensure <textarea> has updated
                setTimeout(function() {
                    // Snap to beginning of output
                    outputTextArea.gotoMark();
                }, 0);

                commandTextArea.clear();
            }
            break;

          case 33: // page up
          case 34: // page down
            outputTextArea.page(e.which == 33);
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

    // $(window).load(function () {
        // twFile is initialized when load() event triggered.
        window.store = new Store();
    // });

    $(window).resize(function(e) {
        outputTextArea.addText('');
    });

    // test();
});

